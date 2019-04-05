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
import Css exposing (..)
import Entity.Category exposing (Category)
import Entity.Image as Image exposing (Image)
import Entity.MediaFormat as MediaFormat
import Entity.Publication as Publication
import Entity.Thumbnail as Thumbnail exposing (Thumbnail)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set
import String
import Task
import Tree exposing (Tree)
import UI.Action as Action
import UI.Background as Background
import UI.Card as Card
import UI.Css.Grid as Grid
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
    , cover : ReloadableWebData () Image
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
    , cover = ReloadableData.NotAsked ()
    , searchText = ""
    }



-- MESSAGE


type Msg
    = LinkClicked String
    | GetPublicationCompleted (ReloadableWebData Int Publication.MetaData)
    | PublicationClicked Int
    | CoverLoaded (ReloadableWebData () Image)
    | NoOp



-- VIEW


view : String -> ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view logoUrl categoryData model =
    UI.Layout.withSideNav
        { title = "Pustaka - Publication"
        , logoUrl = logoUrl
        , sideNav =
            categoryData
                |> UI.Nav.Side.view LinkClicked UI.Nav.Side.NoSelection
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp) model.searchText)
        , content =
            UI.ReloadableData.view
                (viewPublication model)
                model.publication
        , dialog = Dialog.none
        }


viewPublication : Model -> Publication.MetaData -> Html Msg
viewPublication model publication =
    div [ css [ width (pct 100) ] ]
        [ UI.breadCrumb []
        , div
            [ css
                [ width (pct 100)
                , Grid.display
                , UI.paddingTop UI.ExtraLarge
                , Grid.templateColumns [ "auto", "1fr" ]
                ]
            ]
            [ viewInformation model publication
            ]
        ]


viewInformation : Model -> Publication.MetaData -> Html Msg
viewInformation model publication =
    Information.panel
        { title = publication.title
        , poster =
            viewCover
                { publicationId = publication.id
                , cover = model.cover
                , title = publication.title
                }
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


viewCover : { publicationId : Int, cover : ReloadableWebData () Image, title : String } -> Html Msg
viewCover { publicationId, cover, title } =
    Card.bordered [ css [] ]
        { actions = []
        , content =
            [ UI.link
                [ css [ height (pct 100) ] ]
                { msg = LinkClicked
                , url = Route.readUrl publicationId
                , label = UI.reloadablePoster { title = title, image = cover }
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
            loadPoster data { model | publication = data }

        PublicationClicked pubId ->
            ( model, Nav.pushUrl key <| Route.readUrl pubId )

        CoverLoaded data ->
            ( { model | cover = data }, Cmd.none )


loadPoster : ReloadableWebData a Publication.MetaData -> Model -> ( Model, Cmd Msg )
loadPoster data model =
    case ReloadableData.toMaybe data of
        Just publication ->
            if publication.thumbnail |> Thumbnail.hasThumbnail then
                ( { model | cover = ReloadableData.loading model.cover }
                , Publication.downloadCover { publicationId = publication.id, msg = CoverLoaded }
                )

            else
                ( model, Cmd.none )

        Nothing ->
            ( model, Cmd.none )
