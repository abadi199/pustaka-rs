module Reader.Comic exposing (Model, Msg, header, init, next, previous, reader, slider, subscription, update)

import Browser.Dom exposing (Viewport)
import Browser.Navigation as Nav
import Element as E exposing (..)
import Element.Events as EE exposing (onClick)
import Entity.Image as Image
import Entity.Publication as Publication
import Html as H
import Html.Attributes as HA
import Reader exposing (PageView(..))
import ReloadableData exposing (ReloadableWebData)
import UI.Background as Background
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
    , leftPage = ReloadableData.Loading 1
    , rightPage =
        ReloadableData.Loading 1
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
    | GetProgressCompleted (ReloadableWebData Int Float)


subscription : Model -> Sub Msg
subscription model =
    Sub.none



-- VIEW


header : { backUrl : String, publication : Publication.Data, model : Model } -> Element Msg
header { backUrl, publication, model } =
    Header.header
        { visibility = model.overlayVisibility
        , backUrl = backUrl
        , onMouseMove = MouseMoved
        , onLinkClicked = LinkClicked
        , title = publication.title
        }


reader : { publication : Publication.Data, model : Model } -> Element Msg
reader { publication, model } =
    el [ width fill, height fill ] <|
        E.row
            [ width fill, height fill ]
            [ el
                [ width fill
                , height fill
                , Background.transparentMediumBlack
                ]
              <|
                UI.ReloadableData.view Image.fullHeight model.leftPage
            , el
                [ width fill
                , height fill
                , Background.transparentDarkBlack
                ]
              <|
                UI.ReloadableData.view Image.fullHeight model.rightPage
            ]


slider : Model -> Element Msg
slider model =
    case Header.isVisible model.overlayVisibility of
        False ->
            Slider.compact
                { onMouseMove = MouseMoved
                , percentage = 0.25
                , onClick = SliderClicked
                }

        True ->
            Slider.large
                { onMouseMove = MouseMoved
                , percentage = 0.25
                , onClick = SliderClicked
                }


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


update : Nav.Key -> Msg -> { model : Model, publication : Publication.Data } -> ( Model, Cmd Msg )
update key msg { model, publication } =
    case msg of
        LeftImageLoaded data ->
            ( { model | leftPage = data }, Cmd.none )

        RightImageLoaded data ->
            ( { model | rightPage = data }, Cmd.none )

        GetProgressCompleted data ->
            updateProgress { publication = publication, model = model, data = data }

        NextPage ->
            updatePages { publication = publication, model = model, pageUpdater = \page -> page + 2 }

        PreviousPage ->
            updatePages { publication = publication, model = model, pageUpdater = \page -> page - 2 }

        _ ->
            ( model, Cmd.none )


updatePages { model, publication, pageUpdater } =
    let
        updatedModel =
            { model
                | progress =
                    model.progress
                        |> ReloadableData.map (toPageNumber { totalPages = publication.totalPages })
                        |> ReloadableData.map pageUpdater
                        |> ReloadableData.map (toProgress { totalPages = publication.totalPages })
                , leftPage = ReloadableData.loading model.leftPage
                , rightPage = ReloadableData.loading model.rightPage
            }
    in
    ( updatedModel
    , fetchPages { publication = publication, progress = updatedModel.progress }
    )


toPageNumber : { totalPages : Int } -> Publication.Progress -> Int
toPageNumber { totalPages } progress =
    Publication.toPercentage progress * toFloat totalPages |> round


toProgress : { totalPages : Int } -> Int -> Publication.Progress
toProgress { totalPages } page =
    toFloat page / toFloat totalPages |> Publication.percentage


updateProgress : { publication : Publication.Data, model : Model, data : ReloadableWebData Int Float } -> ( Model, Cmd Msg )
updateProgress { publication, model, data } =
    let
        updatedModel =
            { model | progress = data |> ReloadableData.map Publication.percentage }
    in
    ( updatedModel
    , fetchPages { publication = publication, progress = updatedModel.progress }
    )


fetchPages : { publication : Publication.Data, progress : ReloadableWebData Int Publication.Progress } -> Cmd Msg
fetchPages { publication, progress } =
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
                        , page = page
                        , msg = LeftImageLoaded
                        }
                )
            |> Maybe.withDefault Cmd.none
        , maybeRightPage
            |> Maybe.map
                (\page ->
                    Image.get
                        { publicationId = publication.id
                        , page = page
                        , msg = RightImageLoaded
                        }
                )
            |> Maybe.withDefault Cmd.none
        ]
