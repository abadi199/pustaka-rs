module Reader.Comic exposing (Model, Msg, header, init, next, previous, reader, slider, subscription, update)

import Browser.Dom exposing (Viewport)
import Browser.Events
import Browser.Navigation as Nav
import Element as E exposing (..)
import Element.Events as EE exposing (onClick)
import Entity.Image as Image
import Entity.Publication as Publication
import Html as H
import Html.Attributes as HA
import Keyboard
import Reader exposing (PageView(..))
import ReloadableData exposing (ReloadableWebData)
import UI.Background as Background
import UI.Error
import UI.Events
import UI.Icon as Icon
import UI.Image as Image exposing (Image)
import UI.Parts.Header as Header
import UI.Parts.Slider as Slider
import UI.ReloadableData



-- MODEL


type alias Model =
    { overlayVisibility : Header.Visibility
    , progress : ReloadableWebData Int Publication.Progress
    , leftPage : ReloadableWebData Int Image
    , rightPage : ReloadableWebData Int Image
    }


init : Publication.Data -> ( Model, Cmd Msg )
init publication =
    ( initialModel publication
    , Publication.getProgress { publicationId = publication.id, msg = GetProgressCompleted }
    )


initialModel : Publication.Data -> Model
initialModel publication =
    { overlayVisibility = Header.visible counter
    , progress = ReloadableData.Loading publication.id
    , leftPage = ReloadableData.Loading 0
    , rightPage =
        ReloadableData.Loading 0
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
    | LeftImageLoaded (ReloadableWebData Int Image)
    | RightImageLoaded (ReloadableWebData Int Image)
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
                , Background.transparentMediumBlack
                ]
              <|
                UI.ReloadableData.view
                    (\pageImage -> el [ alignRight ] (Image.fullHeight pageImage))
                    model.leftPage
            , el
                [ width fill
                , height fill
                , Background.transparentHeavyBlack
                ]
              <|
                UI.ReloadableData.view
                    (\pageImage -> el [ alignLeft ] (Image.fullHeight pageImage))
                    model.rightPage
            ]


slider : Model -> Element Msg
slider model =
    case ( Header.isVisible model.overlayVisibility, model.progress |> ReloadableData.toMaybe ) of
        ( False, Just progress ) ->
            Slider.compact
                { onMouseMove = MouseMoved
                , percentage = progress |> Publication.toPercentage
                , onClick = SliderClicked
                }

        ( True, Just progress ) ->
            Slider.large
                { onMouseMove = MouseMoved
                , percentage = progress |> Publication.toPercentage
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


update : Nav.Key -> Msg -> Model -> Publication.Data -> ( Model, Cmd Msg )
update key msg model publication =
    case msg of
        LeftImageLoaded data ->
            ( { model | leftPage = data }, Cmd.none )

        RightImageLoaded data ->
            ( { model | rightPage = data }, Cmd.none )

        GetProgressCompleted data ->
            updateProgress publication model data

        NextPage ->
            updatePages publication model { pageUpdater = \page -> page + 2 }

        PreviousPage ->
            updatePages publication model { pageUpdater = \page -> page - 2 }

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

        SliderClicked float ->
            updateProgress publication model (ReloadableData.Success publication.id float)

        _ ->
            ( model, Cmd.none )


updatePages : Publication.Data -> Model -> { pageUpdater : Int -> Int } -> ( Model, Cmd Msg )
updatePages publication model { pageUpdater } =
    let
        data =
            model.progress
                |> ReloadableData.map (toPageNumber { totalPages = publication.totalPages })
                |> ReloadableData.map pageUpdater
                |> ReloadableData.map (toPercentage { totalPages = publication.totalPages })
    in
    if
        data
            |> ReloadableData.map Publication.percentage
            |> ReloadableData.map (toPageNumber { totalPages = publication.totalPages })
            |> ReloadableData.map (checkPagesBoundary { totalPages = publication.totalPages })
            |> ReloadableData.withDefault False
    then
        updateProgress publication model data

    else
        ( model, Cmd.none )


checkPagesBoundary : { totalPages : Int } -> Int -> Bool
checkPagesBoundary { totalPages } pageNumber =
    totalPages - 1 > pageNumber && pageNumber >= 0


toPageNumber : { totalPages : Int } -> Publication.Progress -> Int
toPageNumber { totalPages } progress =
    let
        page =
            Publication.toPercentage progress * toFloat totalPages |> round
    in
    page


toPercentage : { totalPages : Int } -> Int -> Float
toPercentage { totalPages } page =
    toFloat page / toFloat totalPages


updateProgress : Publication.Data -> Model -> ReloadableWebData Int Float -> ( Model, Cmd Msg )
updateProgress publication model data =
    let
        updatedModel =
            { model
                | progress = data |> ReloadableData.map Publication.percentage
                , leftPage = ReloadableData.loading model.leftPage
                , rightPage = ReloadableData.loading model.rightPage
            }
    in
    ( updatedModel
    , Cmd.batch
        [ fetchPages publication updatedModel.progress
        , updatedModel.progress
            |> ReloadableData.map
                (\progress ->
                    Publication.updateProgress
                        { publicationId = publication.id
                        , progress = progress
                        , msg = always NoOp
                        }
                )
            |> ReloadableData.withDefault Cmd.none
        ]
    )


fetchPages : Publication.Data -> ReloadableWebData Int Publication.Progress -> Cmd Msg
fetchPages publication progress =
    let
        maybeLeftPage =
            progress
                |> ReloadableData.toMaybe
                |> Maybe.map Publication.toPercentage
                |> Maybe.map (\percentage -> toFloat publication.totalPages * percentage |> round)

        maybeRightPage =
            maybeLeftPage |> Maybe.map ((+) 1)
    in
    Cmd.batch
        [ maybeLeftPage
            |> Maybe.map
                (\page ->
                    Image.get
                        { publicationId = publication.id
                        , page = page + 1
                        , msg = LeftImageLoaded
                        }
                )
            |> Maybe.withDefault Cmd.none
        , maybeRightPage
            |> Maybe.map
                (\page ->
                    Image.get
                        { publicationId = publication.id
                        , page = page + 1
                        , msg = RightImageLoaded
                        }
                )
            |> Maybe.withDefault Cmd.none
        ]
