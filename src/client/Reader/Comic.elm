module Reader.Comic exposing
    ( Model
    , Msg
    , header
    , init
    , initialModel
    , next
    , previous
    , reader
    , slider
    , subscription
    , update
    , updateProgress
    )

import Browser.Dom exposing (Viewport)
import Browser.Events
import Browser.Navigation as Nav
import Cmd
import Css exposing (..)
import Entity.Image as Image exposing (Image, ReloadableImage)
import Entity.Progress as Progress exposing (Progress)
import Entity.Publication as Publication
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events as HE exposing (onClick)
import Keyboard
import Reader.ComicPage as ComicPage exposing (ComicPage)
import ReloadableData exposing (ReloadableWebData)
import UI.Css.Grid as Grid
import UI.Error
import UI.Events
import UI.Icon as Icon
import UI.Image as Image
import UI.Parts.Header as Header
import UI.Parts.Slider as Slider
import UI.ReloadableData
import UI.Spacing as Spacing



-- MODEL


type alias Model =
    { overlayVisibility : Header.Visibility
    , progress : ReloadableWebData Int Progress
    , pageLayout : PageLayout

    -- , leftPage : ComicPage (ReloadableWebData () Image)
    -- , rightPage : ComicPage (ReloadableWebData () Image)
    }


init viewport publication =
    ( initialModel viewport publication
    , Publication.getProgress { publicationId = publication.id, msg = GetProgressCompleted }
    )


initialModel : Viewport -> Publication.Data -> Model
initialModel viewport publication =
    { overlayVisibility = Header.visible counter
    , progress = ReloadableData.Loading publication.id
    , pageLayout = calculatePageLayout viewport

    -- , leftPage = ComicPage.empty
    -- , rightPage = ComicPage.empty
    }


counter : { counter : Float }
counter =
    { counter = 2000 }



-- MESSAGE


type Msg
    = NoOp
    | MouseMoved
    | LinkClicked String
    | NextPage
    | PreviousPage
    | SliderClicked Float
    | LeftImageLoaded ReloadableImage
    | RightImageLoaded ReloadableImage
    | SingleImageLoaded ReloadableImage
    | Tick Float
    | GetProgressCompleted (ReloadableWebData Int Float)


subscription : Model -> Sub Msg
subscription model =
    Sub.batch
        [ if model.overlayVisibility |> Header.isVisible then
            Browser.Events.onAnimationFrameDelta Tick

          else
            Sub.none
        , Keyboard.onLeft PreviousPage
        , Keyboard.onRight NextPage
        ]



-- VIEW


header : { backUrl : String } -> Publication.Data -> Model -> Html Msg
header { backUrl } publication model =
    Header.header
        { visibility = model.overlayVisibility
        , backUrl = backUrl
        , onMouseMove = MouseMoved
        , onLinkClicked = LinkClicked
        , title = publication.title
        }


type PageLayout
    = SinglePageLayout ComicPage
    | DoublePagesLayout { left : ComicPage, right : ComicPage }


calculatePageLayout : Viewport -> PageLayout
calculatePageLayout viewport =
    if viewport.viewport.width >= viewport.viewport.height then
        DoublePagesLayout { left = ComicPage.empty, right = ComicPage.empty }

    else
        SinglePageLayout ComicPage.empty


setLeftPage : ReloadableImage -> PageLayout -> PageLayout
setLeftPage data pageLayout =
    case pageLayout of
        DoublePagesLayout pages ->
            DoublePagesLayout { pages | left = ComicPage.set data pages.left }

        SinglePageLayout _ ->
            pageLayout


setRightPage : ReloadableImage -> PageLayout -> PageLayout
setRightPage data pageLayout =
    case pageLayout of
        DoublePagesLayout pages ->
            DoublePagesLayout { pages | right = ComicPage.set data pages.right }

        SinglePageLayout _ ->
            pageLayout


setSinglePage : ReloadableImage -> PageLayout -> PageLayout
setSinglePage data pageLayout =
    case pageLayout of
        DoublePagesLayout _ ->
            pageLayout

        SinglePageLayout page ->
            SinglePageLayout (ComicPage.set data page)


reader : { viewport : Viewport, publication : Publication.Data, model : Model } -> Html Msg
reader ({ model } as args) =
    case model.pageLayout of
        SinglePageLayout page ->
            singlePageReader model.pageLayout page

        DoublePagesLayout pages ->
            dualPagesReader model.pageLayout pages


singlePageReader : PageLayout -> ComicPage -> Html Msg
singlePageReader pageLayout page =
    div
        [ css
            [ width (pct 100)
            , height (pct 100)
            , Grid.display
            , Grid.templateColumns [ "100%" ]
            , overflowX auto
            ]
        , UI.Events.onMouseMove MouseMoved
        ]
        [ viewPage
            (css
                [ displayFlex
                , justifyContent flexStart
                , position relative
                , height (pct 100)
                , width (pct 100)
                , overflowY auto
                ]
            )
            pageLayout
            page
        ]


dualPagesReader : PageLayout -> { left : ComicPage, right : ComicPage } -> Html Msg
dualPagesReader pageLayout { left, right } =
    div
        [ css
            [ width (pct 100)
            , height (pct 100)
            , Grid.display
            , Grid.templateColumns [ "50%", "50%" ]
            , Grid.templateAreas [ "left right" ]
            ]
        , UI.Events.onMouseMove MouseMoved
        ]
        [ viewPage
            (css
                [ displayFlex
                , justifyContent flexStart
                , position relative
                , height (pct 100)
                , width (pct 100)
                , Grid.area "left"
                , overflowY auto
                ]
            )
            pageLayout
            left
        , viewPage
            (css
                [ textAlign Css.left
                , displayFlex
                , justifyContent flexStart
                , position relative
                , height (pct 100)
                , width (pct 100)
                , Grid.area "right"
                , overflowY auto
                ]
            )
            pageLayout
            right
        ]


viewPage : Attribute Msg -> PageLayout -> ComicPage -> Html Msg
viewPage alignment pageLayout page =
    case page of
        ComicPage.Empty ->
            text ""

        ComicPage.Page number data ->
            UI.ReloadableData.view
                (\pageImage ->
                    div [ alignment ]
                        [ Image.fullHeight pageImage
                        , viewPageNumber pageLayout number
                        ]
                )
                data

        ComicPage.OutOfBound ->
            UI.Error.string "Out of bound"


viewPageNumber : PageLayout -> Int -> Html msg
viewPageNumber pageLayout number =
    div
        [ css
            [ position absolute
            , bottom (px 0)
            , case pageLayout of
                SinglePageLayout _ ->
                    right (px 0)

                DoublePagesLayout _ ->
                    if remainderBy 2 number == 0 then
                        right (px 0)

                    else
                        left (px 0)
            , Spacing.paddingEach
                { bottom = Spacing.Large
                , top = Spacing.None
                , left = Spacing.Large
                , right = Spacing.Large
                }
            , textShadow4 (px 0) (px 0) (px 2) (rgba 255 255 255 0.5)
            ]
        ]
        [ text <| String.fromInt number ]


slider : Model -> Html Msg
slider model =
    case ( Header.isVisible model.overlayVisibility, model.progress |> ReloadableData.toMaybe ) of
        ( False, Just progress ) ->
            Slider.compact
                { onMouseMove = MouseMoved
                , percentage = progress |> Progress.toFloat
                , onClick = SliderClicked
                }

        ( True, Just progress ) ->
            Slider.large
                { onMouseMove = MouseMoved
                , percentage = progress |> Progress.toFloat
                , onClick = SliderClicked
                }

        ( _, Nothing ) ->
            text ""


previous : Html Msg
previous =
    div
        [ onClick PreviousPage
        , css
            [ height (pct 100)
            , cursor pointer
            , displayFlex
            , justifyContent center
            , alignItems center
            , hover
                [ backgroundColor (rgba 0 0 0 0.025)
                ]
            ]
        ]
        [ Icon.previous Icon.large ]


next : Html Msg
next =
    div
        [ onClick NextPage
        , css
            [ height (pct 100)
            , cursor pointer
            , displayFlex
            , justifyContent center
            , alignItems center
            , hover
                [ backgroundColor (rgba 0 0 0 0.025)
                ]
            ]
        ]
        [ Icon.next Icon.large ]


image : Int -> Int -> Html msg
image pubId pageNum =
    H.img
        [ HA.src <| imageUrl pubId pageNum
        , HA.style "height" "100vh"
        ]
        []


imageUrl : Int -> Int -> String
imageUrl pubId pageNum =
    "/api/publication/read/"
        ++ String.fromInt pubId
        ++ "/page/"
        ++ String.fromInt pageNum



-- UPDATE


update : Nav.Key -> Viewport -> Msg -> Model -> Publication.Data -> ( Model, Cmd Msg )
update _ viewport msg model publication =
    let
        pageLayout =
            calculatePageLayout viewport
    in
    case msg of
        LeftImageLoaded data ->
            ( { model | pageLayout = setLeftPage data model.pageLayout }, Cmd.none )

        RightImageLoaded data ->
            ( { model | pageLayout = setRightPage data model.pageLayout }, Cmd.none )

        SingleImageLoaded data ->
            ( { model | pageLayout = setSinglePage data model.pageLayout }, Cmd.none )

        Tick delta ->
            model.overlayVisibility
                |> Header.toCounter
                |> Maybe.map (\currentCounter -> currentCounter - delta)
                |> Maybe.map Header.visibilityFromCounter
                |> Maybe.map
                    (\visibility ->
                        ( { model | overlayVisibility = visibility }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        MouseMoved ->
            ( { model | overlayVisibility = Header.visible counter }, Cmd.none )

        GetProgressCompleted data ->
            updateProgress publication model data

        NextPage ->
            model.progress
                |> calculateNextPercentage (+) pageLayout publication
                |> updateProgress publication model
                |> Cmd.alsoDo (submitProgress publication)

        PreviousPage ->
            model.progress
                |> calculateNextPercentage (-) pageLayout publication
                |> updateProgress publication model
                |> Cmd.alsoDo (submitProgress publication)

        SliderClicked float ->
            float
                |> ReloadableData.Success publication.id
                |> updateProgress publication model
                |> Cmd.alsoDo (submitProgress publication)

        _ ->
            ( model, Cmd.none )


updateProgress : Publication.Data -> Model -> ReloadableWebData Int Float -> ( Model, Cmd Msg )
updateProgress publication model data =
    case data of
        ReloadableData.Success _ unclampedPercentage ->
            case model.pageLayout of
                SinglePageLayout page ->
                    updateSinglePageProgress publication unclampedPercentage page model

                DoublePagesLayout pages ->
                    updateDoublePagesProgress publication unclampedPercentage pages model

        _ ->
            ( model, Cmd.none )


updateSinglePageProgress : Publication.Data -> Float -> ComicPage -> Model -> ( Model, Cmd Msg )
updateSinglePageProgress publication unclampedPercentage page model =
    let
        percentage =
            unclampedPercentage |> clamp 0 100

        updatedPage =
            page
                |> ComicPage.toSinglePage (ReloadableData.Loading ())
                    ReloadableData.loading
                    { totalPages = publication.totalPages, percentage = percentage }

        progress =
            ReloadableData.Success publication.id (Progress.percentage percentage)

        updatedModel =
            { model
                | progress = progress
                , pageLayout = SinglePageLayout updatedPage
            }

        cmd =
            Cmd.batch
                [ updatedPage
                    |> ComicPage.toPageNumber
                    |> Maybe.map
                        (\pageNumber ->
                            Publication.downloadPage
                                { publicationId = publication.id
                                , page = pageNumber
                                , msg = SingleImageLoaded
                                }
                        )
                    |> Maybe.withDefault Cmd.none
                ]
    in
    ( updatedModel, cmd )


updateDoublePagesProgress : Publication.Data -> Float -> { left : ComicPage, right : ComicPage } -> Model -> ( Model, Cmd Msg )
updateDoublePagesProgress publication unclampedPercentage { left, right } model =
    let
        percentage =
            unclampedPercentage |> clamp 0 100

        leftPage =
            left
                |> ComicPage.toLeftPage (ReloadableData.Loading ())
                    ReloadableData.loading
                    { totalPages = publication.totalPages, percentage = percentage }

        rightPage =
            right
                |> ComicPage.toRightPage (ReloadableData.Loading ())
                    ReloadableData.loading
                    { totalPages = publication.totalPages, percentage = percentage }

        progress =
            ReloadableData.Success publication.id (Progress.percentage percentage)

        updatedModel =
            { model
                | progress = progress
                , pageLayout = DoublePagesLayout { left = leftPage, right = rightPage }
            }

        cmd =
            Cmd.batch
                [ leftPage
                    |> ComicPage.toPageNumber
                    |> Maybe.map
                        (\pageNumber ->
                            Publication.downloadPage
                                { publicationId = publication.id
                                , page = pageNumber
                                , msg = LeftImageLoaded
                                }
                        )
                    |> Maybe.withDefault Cmd.none
                , rightPage
                    |> ComicPage.toPageNumber
                    |> Maybe.map
                        (\pageNumber ->
                            Publication.downloadPage
                                { publicationId = publication.id
                                , page = pageNumber
                                , msg = RightImageLoaded
                                }
                        )
                    |> Maybe.withDefault Cmd.none
                ]
    in
    ( updatedModel, cmd )


calculateNextPercentage :
    (Float -> Float -> Float)
    -> PageLayout
    -> Publication.Data
    -> ReloadableWebData Int Progress
    -> ReloadableWebData Int Float
calculateNextPercentage operator pageLayout publication progress =
    let
        delta =
            100 / toFloat (publication.totalPages - 1)

        multiplier =
            case pageLayout of
                SinglePageLayout _ ->
                    1

                DoublePagesLayout _ ->
                    2
    in
    progress
        |> ReloadableData.map Progress.toFloat
        |> ReloadableData.map (\float -> operator float (delta * multiplier))


submitProgress : Publication.Data -> Model -> Cmd Msg
submitProgress publication model =
    model.progress
        |> ReloadableData.toMaybe
        |> Maybe.map
            (\progress ->
                Publication.updateProgress
                    { publicationId = publication.id
                    , progress = progress
                    , msg = always NoOp
                    }
            )
        |> Maybe.withDefault Cmd.none
