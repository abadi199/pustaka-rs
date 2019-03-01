module Page.Read exposing
    ( Model
    , Msg
    , init
    , initialModel
    , subscriptions
    , update
    , view
    )

import Browser
import Browser.Dom exposing (Viewport)
import Browser.Events
import Browser.Navigation as Nav
import Element as E exposing (..)
import Element.Border as Border exposing (shadow)
import Element.Events as Events exposing (onClick, onMouseEnter)
import Element.Font as Font
import Entity.MediaFormat as MediaFormat exposing (MediaFormat(..))
import Entity.Publication as Publication
import Html exposing (Html)
import Html.Attributes as HA
import Keyboard
import Reader exposing (PageView(..))
import Reader.Comic as Comic
import Reader.Epub as Epub
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Task
import UI.Icon as Icon
import UI.Link as UI
import UI.ReloadableData
import UI.Spacing as UI



-- MODEL


type alias Model =
    { publication : ReloadableWebData Int Publication.Data
    , currentPage : PageView
    , previousUrl : Maybe String
    , headerVisibility : HeaderVisibility
    }


type HeaderVisibility
    = Hidden
    | Visible { counter : Float }


headerVisibleDuration : Float
headerVisibleDuration =
    2000



-- INIT


init : Int -> Maybe String -> ( Model, Cmd Msg )
init pubId previousUrl =
    ( initialModel pubId previousUrl
    , Publication.read { publicationId = pubId, msg = GetDataCompleted }
    )


initialModel : Int -> Maybe String -> Model
initialModel pubId previousUrl =
    { publication = Loading pubId
    , currentPage = DoublePage 1
    , previousUrl = previousUrl
    , headerVisibility = Visible { counter = headerVisibleDuration }
    }



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onAnimationFrameDelta Tick
        , Keyboard.onLeft PreviousPage
        , Keyboard.onRight NextPage
        , Keyboard.onEscape BackLinkClicked
        ]



-- MESSAGE


type Msg
    = GetDataCompleted (ReloadableWebData Int Publication.Data)
    | NextPage
    | PreviousPage
    | BackLinkClicked
    | Tick Float
    | ReaderClicked



-- VIEW


view : Viewport -> Model -> Browser.Document Msg
view viewport model =
    { title = "Read"
    , body =
        UI.ReloadableData.view
            (\pub ->
                row
                    [ inFront <| header pub model
                    , width fill
                    ]
                    [ left pub model.previousUrl
                    , pages viewport pub model.currentPage
                    , right pub
                    ]
            )
            model.publication
            |> E.layout []
            |> List.singleton
    }


header : Publication.Data -> Model -> Element Msg
header pub model =
    case model.headerVisibility of
        Hidden ->
            none

        Visible _ ->
            row
                [ width fill
                , Border.shadow
                    { offset = ( 0, 0 )
                    , size = 0
                    , blur = 10
                    , color = rgba 0 0 0 0.5
                    }
                , UI.padding -2
                ]
                [ UI.link
                    []
                    { url =
                        model.previousUrl
                            |> Maybe.withDefault (Route.publicationUrl pub.id)
                    , label =
                        text "<< Back"
                    , msg = always BackLinkClicked
                    }
                , el [ width fill, centerX, Font.center ] (text pub.title)
                ]


left : Publication.Data -> Maybe String -> Element Msg
left pub previousUrl =
    row
        [ onClick PreviousPage
        , alignLeft
        , height fill
        , pointer
        ]
        [ Icon.previous Icon.large ]


pages : Viewport -> Publication.Data -> PageView -> Element Msg
pages viewport pub pageView =
    el
        [ centerX
        , onMouseEnter ReaderClicked
        ]
    <|
        case pub.mediaFormat of
            CBZ ->
                Comic.reader pub pageView

            CBR ->
                Comic.reader pub pageView

            Epub ->
                Epub.reader viewport pub pageView

            NoMediaFormat ->
                Debug.todo "No media format"


right : Publication.Data -> Element Msg
right pub =
    row
        [ onClick NextPage
        , alignRight
        , height fill
        , pointer
        ]
        [ Icon.next Icon.large ]


previousPage : PageView -> PageView
previousPage currentPage =
    case currentPage of
        DoublePage a ->
            DoublePage (a - 2)

        SinglePage a ->
            SinglePage (a - 1)


nextPage : PageView -> PageView
nextPage currentPage =
    case currentPage of
        DoublePage a ->
            DoublePage (a + 2)

        SinglePage a ->
            SinglePage (a + 1)



-- UPDATE


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        GetDataCompleted data ->
            ( { model | publication = data }, Cmd.none )

        PreviousPage ->
            ( { model | currentPage = previousPage model.currentPage }, Cmd.none )

        NextPage ->
            ( { model | currentPage = nextPage model.currentPage }, Cmd.none )

        BackLinkClicked ->
            ( model, model.publication |> ReloadableData.toInitial |> Route.publicationUrl |> Nav.pushUrl key )

        Tick delta ->
            ( updateHeaderVisibility delta model, Cmd.none )

        ReaderClicked ->
            ( { model | headerVisibility = Visible { counter = headerVisibleDuration } }, Cmd.none )


updateHeaderVisibility : Float -> Model -> Model
updateHeaderVisibility delta model =
    case model.headerVisibility of
        Hidden ->
            model

        Visible { counter } ->
            if counter - delta <= 0 then
                { model | headerVisibility = Hidden }

            else
                { model | headerVisibility = Visible { counter = counter - delta } }
