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
    , progress : Publication.Progress
    , leftPage : ReloadableWebData Int Image
    , rightPage : ReloadableWebData Int Image
    }


init : Publication.Data -> ( Model, Cmd Msg )
init publication =
    ( initialModel
    , Cmd.batch
        [ Image.get
            { publicationId = publication.id
            , page = 1
            , msg = LeftImageLoaded
            }
        , Image.get
            { publicationId = publication.id
            , page = 2
            , msg = RightImageLoaded
            }
        ]
    )


initialModel : Model
initialModel =
    { overlayVisibility = Header.visible counter
    , progress = Publication.percentage 0
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
    let
        pageLeft =
            1

        pageRight =
            2
    in
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

        _ ->
            ( model, Cmd.none )
