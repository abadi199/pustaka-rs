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
import Element.Background as Background
import Element.Region as Region
import Entity.Category exposing (Category)
import Entity.MediaFormat as MediaFormat
import Entity.Publication as Publication
import Entity.Thumbnail as Thumbnail exposing (Thumbnail)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set
import String
import Task
import Tree exposing (Tree)
import UI.Action as Action
import UI.Background as Background
import UI.Card as Card
import UI.Heading as UI
import UI.Icon as Icon
import UI.Layout
import UI.Link as UI
import UI.Nav.Side
import UI.Parts.BreadCrumb as UI
import UI.Parts.Dialog as Dialog
import UI.Parts.Information as Information
import UI.Parts.Search
import UI.Poster as UI
import UI.ReloadableData
import UI.Spacing as UI



-- MODEL


type alias Model =
    { publication : ReloadableWebData Int Publication.MetaData
    , searchText : String
    }


init : Int -> ( Model, Cmd Msg )
init publicationId =
    ( initialModel publicationId
    , Publication.get { publicationId = publicationId, msg = GetPublicationCompleted }
    )


initialModel : Int -> Model
initialModel publicationId =
    { publication = ReloadableData.Loading publicationId
    , searchText = ""
    }



-- MESSAGE


type Msg
    = LinkClicked String
    | GetPublicationCompleted (ReloadableWebData Int Publication.MetaData)
    | PublicationClicked Int
    | NoOp



-- VIEW


view : ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view categoryData model =
    UI.Layout.withSideNav
        { title = "Pustaka - Publication"
        , sideNav =
            categoryData
                |> UI.Nav.Side.view LinkClicked UI.Nav.Side.NoSelection
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp) model.searchText)
        , content =
            UI.ReloadableData.view
                viewPublication
                model.publication
        , dialog = Dialog.none
        }


viewPublication : Publication.MetaData -> Element Msg
viewPublication publication =
    column [ UI.spacing 1, width fill ]
        [ UI.breadCrumb []
        , row
            [ UI.spacing 1, width fill ]
            [ viewPoster publication.id publication.thumbnail publication.title
            , viewInformation publication
            ]
        ]


viewInformation : Publication.MetaData -> Element Msg
viewInformation publication =
    Information.panel
        { title = publication.title
        , informationList =
            [ { term = "Author", details = "N/A", onClick = NoOp }
            , { term = "ISBN", details = publication.isbn, onClick = NoOp }
            , { term = "Format", details = MediaFormat.toString publication.mediaFormat, onClick = NoOp }
            , { term = "Media", details = "N/A", onClick = NoOp }
            , { term = "File", details = publication.file, onClick = NoOp }
            ]
        , actions =
            [ Action.large <|
                Action.link
                    { text = "Edit"
                    , icon = Icon.edit Icon.small
                    , url = Route.publicationEditUrl publication.id
                    , onClick = LinkClicked
                    }
            , Action.large <|
                Action.link
                    { text = "Read"
                    , icon = Icon.read Icon.small
                    , url = Route.readUrl publication.id
                    , onClick = LinkClicked
                    }
            ]
        }


viewPoster : Int -> Thumbnail -> String -> Element Msg
viewPoster publicationId thumbnail title =
    Card.bordered [ alignTop ]
        { actions = []
        , content =
            [ UI.link
                [ height fill ]
                { msg = LinkClicked
                , url = Route.readUrl publicationId
                , label = UI.poster { title = title, thumbnail = thumbnail }
                }
            ]
        }



-- UPDATE


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked url ->
            ( model, Nav.pushUrl key url )

        GetPublicationCompleted data ->
            ( { model | publication = data }, Cmd.none )

        PublicationClicked pubId ->
            ( model, Nav.pushUrl key <| Route.readUrl pubId )
