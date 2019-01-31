module Page.Publication exposing
    ( Model
    , Msg
    , init
    , initialModel
    , update
    , view
    )

import Browser
import Browser.Navigation as Nav
import Element as E exposing (..)
import Element.Region as Region
import Entity.Category exposing (Category)
import Entity.Publication as Publication
import Html.Extra exposing (link)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set
import String
import Task
import Tree exposing (Tree)
import UI.Layout
import UI.Nav.Side
import UI.Parts.Search
import UI.Poster as UI
import UI.ReloadableData


view : ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view categoryData model =
    UI.Layout.withSideNav
        { title = "Pustaka - Publication"
        , sideNav =
            categoryData
                |> UI.Nav.Side.view MenuItemClicked UI.Nav.Side.NoSelection
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp) model.searchText)
        , content =
            UI.ReloadableData.view
                publicationView
                model.publication
        }


publicationView : Publication.MetaData -> Element Msg
publicationView publication =
    column []
        [ el [ Region.heading 2 ] (text publication.title)
        , posterView publication.id publication.thumbnail publication.title
        ]


posterView : Int -> Maybe String -> String -> Element Msg
posterView publicationId maybePoster title =
    el []
        (link MenuItemClicked
            []
            (Route.readUrl publicationId)
            (UI.poster title maybePoster)
        )


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MenuItemClicked url ->
            ( model, Nav.pushUrl key url )

        GetPublicationCompleted data ->
            ( { model | publication = data }, Cmd.none )

        PublicationClicked pubId ->
            ( model, Nav.pushUrl key <| Route.readUrl pubId )


type alias Model =
    { publication : ReloadableWebData Int Publication.MetaData
    , searchText : String
    }


init : Int -> ( Model, Cmd Msg )
init publicationId =
    ( initialModel publicationId
    , Publication.get publicationId |> Task.perform GetPublicationCompleted
    )


initialModel : Int -> Model
initialModel publicationId =
    { publication = ReloadableData.Loading publicationId
    , searchText = ""
    }


type Msg
    = MenuItemClicked String
    | GetPublicationCompleted (ReloadableWebData Int Publication.MetaData)
    | PublicationClicked Int
    | NoOp
