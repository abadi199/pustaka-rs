module Page.Read exposing
    ( Model
    , Msg
    , init
    , initialModel
    , update
    , view
    )

import Browser
import Css exposing (..)
import Entity.Publication as Publication exposing (MediaFormat(..))
import Html.Extra
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import Reader exposing (PageView(..))
import Reader.Comic as Comic
import Reader.Epub as Epub
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Task
import UI.ReloadableData


type alias Model =
    { publication : ReloadableWebData Int Publication.Data
    , currentPage : PageView
    , previousUrl : Maybe String
    }


type Msg
    = GetDataCompleted (ReloadableWebData Int Publication.Data)
    | NextPage
    | PreviousPage
    | BackLinkClicked


init : Int -> Maybe String -> ( Model, Cmd Msg )
init pubId previousUrl =
    ( initialModel pubId previousUrl
    , Publication.read pubId |> Task.perform GetDataCompleted
    )


initialModel : Int -> Maybe String -> Model
initialModel pubId previousUrl =
    { publication = Loading pubId
    , currentPage = DoublePage 1
    , previousUrl = previousUrl
    }


view : Model -> Browser.Document Msg
view model =
    { title = "Read"
    , body =
        UI.ReloadableData.view
            (\pub ->
                div
                    [ css
                        [ displayFlex
                        , flexDirection row
                        , flexWrap noWrap
                        , alignItems center
                        , Css.height (vh 100)
                        ]
                    ]
                    [ left pub model.previousUrl
                    , pages pub model.currentPage
                    , right pub
                    ]
            )
            model.publication
            |> List.map Html.Styled.toUnstyled
    }


left : Publication.Data -> Maybe String -> Html Msg
left pub previousUrl =
    div
        [ css
            [ backgroundColor (rgba 0 0 0 0.95)
            , color (rgba 255 255 255 1)
            , flex (int 1)
            , Css.height (pct 100)
            ]
        , onClick PreviousPage
        ]
        [ div [] [ text pub.title ]
        , div [] [ Html.Extra.link (always BackLinkClicked) (previousUrl |> Maybe.withDefault (Route.publicationUrl pub.id)) [] [ text "<< Back" ] ]
        ]


pages : Publication.Data -> PageView -> Html Msg
pages pub pageView =
    case pub.mediaFormat of
        CBZ ->
            Comic.reader pub pageView

        CBR ->
            Comic.reader pub pageView

        Epub ->
            Epub.reader pub pageView


right : Publication.Data -> Html Msg
right pub =
    div
        [ css
            [ backgroundColor (rgba 0 0 0 0.95)
            , flex (int 1)
            , Css.height (pct 100)
            ]
        , onClick NextPage
        ]
        []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetDataCompleted data ->
            ( { model | publication = data }, Cmd.none )

        PreviousPage ->
            ( { model | currentPage = previousPage model.currentPage }, Cmd.none )

        NextPage ->
            ( { model | currentPage = nextPage model.currentPage }, Cmd.none )

        BackLinkClicked ->
            ( model, Cmd.none )


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
