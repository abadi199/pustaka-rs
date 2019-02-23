module Page.Publication.Edit exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Browser
import Browser.Navigation as Nav
import Element as E exposing (..)
import Entity.Category exposing (Category)
import Entity.Publication as Publication
import ReloadableData exposing (ReloadableWebData)
import Task
import UI.Layout
import UI.Nav.Side
import UI.Parts.BreadCrumb as UI
import UI.Parts.Search
import UI.ReloadableData
import UI.Spacing as UI



-- MODEL


type alias Model =
    { searchText : String
    , publication : ReloadableWebData Int Publication.MetaData
    }


init : Int -> ( Model, Cmd Msg )
init publicationId =
    ( { searchText = ""
      , publication = ReloadableData.Loading publicationId
      }
    , Publication.get publicationId |> Task.perform GetPublicationCompleted
    )



-- MESSAGE


type Msg
    = NoOp
    | LinkClicked String
    | GetPublicationCompleted (ReloadableWebData Int Publication.MetaData)



-- VIEW


view : ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view categories model =
    UI.Layout.withSideNav
        { title = "Pustaka - Edit Publication"
        , sideNav =
            categories
                |> UI.Nav.Side.view LinkClicked UI.Nav.Side.NoSelection
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp) model.searchText)
        , content =
            UI.ReloadableData.view
                viewEdit
                model.publication
        }


viewEdit : Publication.MetaData -> Element Msg
viewEdit publication =
    column [ UI.spacing 2, width fill ]
        [ UI.breadCrumb []
        , E.text "Edit Publication"
        ]



-- UPDATE


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked url ->
            ( model, Nav.pushUrl key url )

        GetPublicationCompleted reloadableData ->
            ( { model | publication = reloadableData }, Cmd.none )
