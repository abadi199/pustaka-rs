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

import Browser.Events
import Browser.Navigation as Nav
import Cmd
import Element as E exposing (..)
import Element.Events as EE exposing (onClick)
import Entity.Image as Image exposing (Image)
import Entity.Progress as Progress exposing (Progress)
import Entity.Publication as Publication
import Html as H
import Html.Attributes as HA
import Keyboard
import Reader.ComicPage as ComicPage exposing (ComicPage)
import ReloadableData exposing (ReloadableWebData)
import UI.Background as Background
import UI.Error
import UI.Events
import UI.Icon as Icon
import UI.Image as Image
import UI.Parts.Header as Header
import UI.Parts.Slider as Slider
import UI.ReloadableData



-- MODEL


type alias Model =
    { overlayVisibility : Header.Visibility
    , progress : ReloadableWebData Int Progress
    , leftPage : ComicPage (ReloadableWebData () Image)
    , rightPage : ComicPage (ReloadableWebData () Image)
    }


init publication =
    ( initialModel publication
    , Publication.getProgress { publicationId = publication.id, msg = GetProgressCompleted }
    )


initialModel : Publication.Data -> Model
initialModel publication =
    { overlayVisibility = Header.visible counter
    , progress = ReloadableData.Loading publication.id
    , leftPage = ComicPage.empty
    , rightPage = ComicPage.empty
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
    | LeftImageLoaded (ReloadableWebData () Image)
    | RightImageLoaded (ReloadableWebData () Image)
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


header : { backUrl : String } -> Publication.Data -> Model -> Element Msg
header { backUrl } publication model =
    Header.header
        { visibility = model.overlayVisibility
        , backUrl = backUrl
        , onMouseMove = MouseMoved
        , onLinkClicked = LinkClicked
        , title = publication.title
        }


reader : Publication.Data -> Model -> Element Msg
reader publication model =
    el
        [ width fill
        , height fill
        , UI.Events.onMouseMove MouseMoved
        ]
    <|
        E.row
            [ width fill, height fill ]
            [ el
                [ width fill
                , height fill
                , Background.solidWhite
                ]
              <|
                viewPage alignRight model.leftPage
            , el
                [ width fill
                , height fill
                , Background.solidWhite
                ]
              <|
                viewPage alignLeft model.rightPage
            ]


viewPage : Attribute Msg -> ComicPage (ReloadableWebData () Image) -> Element Msg
viewPage alignment page =
    case page of
        ComicPage.Empty ->
            E.none

        ComicPage.Page number data ->
            UI.ReloadableData.view
                (\pageImage ->
                    el [ width fill, inFront (viewPageNumber number) ] (el [ alignment ] (Image.fullHeight pageImage))
                )
                data

        ComicPage.OutOfBound ->
            UI.Error.string "Out of bound"


viewPageNumber : Int -> Element msg
viewPageNumber number =
    el
        [ alignBottom
        , if remainderBy 2 number == 0 then
            alignRight

          else
            alignLeft
        , paddingEach { bottom = 10, top = 0, left = 0, right = 0 }
        ]
        (text <| String.fromInt number)


slider : Model -> Element Msg
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
            none


previous : Element Msg
previous =
    row
        [ onClick PreviousPage
        , alignLeft
        , height fill
        , pointer
        ]
        [ Icon.previous Icon.large ]


next : Element Msg
next =
    row
        [ onClick NextPage
        , alignRight
        , height fill
        , pointer
        ]
        [ Icon.next Icon.large ]


image : Int -> Int -> Element msg
image pubId pageNum =
    E.html <|
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


update : Nav.Key -> Msg -> Model -> Publication.Data -> ( Model, Cmd Msg )
update key msg model publication =
    case msg of
        LeftImageLoaded data ->
            ( { model | leftPage = ComicPage.map (always data) model.leftPage }, Cmd.none )

        RightImageLoaded data ->
            ( { model | rightPage = ComicPage.map (always data) model.rightPage }, Cmd.none )

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
                |> calculateNextPercentage (+) publication
                |> updateProgress publication model
                |> Cmd.alsoDo (submitProgress publication)

        PreviousPage ->
            model.progress
                |> calculateNextPercentage (-) publication
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
            let
                percentage =
                    unclampedPercentage |> clamp 0 100 |> Debug.log "progress"

                leftPage =
                    model.leftPage
                        |> ComicPage.toLeftPage (ReloadableData.Loading ())
                            ReloadableData.loading
                            { totalPages = publication.totalPages, percentage = percentage }

                rightPage =
                    model.rightPage
                        |> ComicPage.toRightPage (ReloadableData.Loading ())
                            ReloadableData.loading
                            { totalPages = publication.totalPages, percentage = percentage }

                progress =
                    ReloadableData.Success publication.id (Progress.percentage percentage)

                updatedModel =
                    { model
                        | leftPage = leftPage
                        , rightPage = rightPage
                        , progress = progress
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

        _ ->
            ( model, Cmd.none )


calculateNextPercentage :
    (Float -> Float -> Float)
    -> Publication.Data
    -> ReloadableWebData Int Progress
    -> ReloadableWebData Int Float
calculateNextPercentage operator publication progress =
    let
        delta =
            100 / toFloat (publication.totalPages - 1)
    in
    progress
        |> ReloadableData.map Progress.toFloat
        |> ReloadableData.map (Debug.log "from")
        |> ReloadableData.map (\float -> operator float (delta * 2))
        |> ReloadableData.map (Debug.log "to")


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
