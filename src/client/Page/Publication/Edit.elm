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
import UI.Parts.Form as Form
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
    | PublicationChanged Field
    | FormSubmitted
    | SubmissionCompleted (ReloadableWebData Int ())


type Field
    = TitleField String
    | ISBNField String



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
        , Form.form
            { fields =
                [ Form.field
                    { label = "Title"
                    , value = publication.title
                    , onChange = TitleField >> PublicationChanged
                    }
                , Form.field
                    { label = "ISBN"
                    , value = publication.isbn
                    , onChange = ISBNField >> PublicationChanged
                    }
                ]
            , onSubmit = FormSubmitted
            }
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
            ( { model | publication = reloadableData }
            , Cmd.none
            )

        PublicationChanged value ->
            ( { model | publication = model.publication |> ReloadableData.map (updatePublication value) }
            , Cmd.none
            )

        FormSubmitted ->
            ( { model
                | publication =
                    model.publication
                        |> ReloadableData.loading
              }
            , model.publication
                |> ReloadableData.toMaybe
                |> Maybe.map (Publication.update >> Task.perform SubmissionCompleted)
                |> Maybe.withDefault Cmd.none
            )

        SubmissionCompleted reloadableData ->
            ( model, Cmd.none )


updatePublication : Field -> Publication.MetaData -> Publication.MetaData
updatePublication field publication =
    case field of
        TitleField value ->
            { publication | title = value }

        ISBNField value ->
            { publication | isbn = value }
