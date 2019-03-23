module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , initialModel
    , selectCategory
    , update
    , view
    )

import Browser
import Browser.Navigation as Nav
import Cmd
import Dict exposing (Dict)
import Element as E exposing (..)
import Entity.Category exposing (Category)
import Entity.Image as Image exposing (Image)
import Entity.Publication as Publication
import Entity.Thumbnail as Thumbnail
import Html.Attributes as HA
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set exposing (Set)
import Tree exposing (Tree)
import UI.Action as Action
import UI.Background as Background
import UI.Card as Card
import UI.Error
import UI.Heading as Heading
import UI.Icon as Icon
import UI.Layout
import UI.Loading
import UI.Menu
import UI.Nav.Side
import UI.Parts.BreadCrumb as BreadCrumb
import UI.Parts.Dialog as Dialog
import UI.Parts.Search
import UI.Poster as UI
import UI.ReloadableData
import UI.Spacing as UI



-- MODEL


type alias Model =
    { selectedCategoryId : Maybe Int
    , publications : ReloadableWebData () (List Publication.MetaData)
    , recentPublications : ReloadableWebData () (List Publication.MetaData)
    , covers : Dict Int (ReloadableWebData () Image)
    , searchText : String
    }


init : Maybe Int -> ( Model, Cmd Msg )
init selectedCategoryId =
    selectCategory selectedCategoryId initialModel
        |> Cmd.andThen updateRecentPublications


initialModel : Model
initialModel =
    { selectedCategoryId = Nothing
    , publications = ReloadableData.NotAsked ()
    , recentPublications = ReloadableData.NotAsked ()
    , covers = Dict.empty
    , searchText = ""
    }



-- MESSAGE


type Msg
    = NoOp
    | LinkClicked String
    | CategorySelected (Maybe Int)
    | GetPublicationCompleted (ReloadableWebData () (List Publication.MetaData))
    | CoverDownloaded Int (ReloadableWebData () Image)
    | GetRecentPublicationCompleted (ReloadableWebData () (List Publication.MetaData))



-- VIEW


view : Nav.Key -> ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view key categories model =
    UI.Layout.withSideNav
        { title = "Pustaka - Home"
        , sideNav =
            categories
                |> UI.Nav.Side.view LinkClicked (selectedItem model.selectedCategoryId)
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp) model.searchText)
        , content =
            case model.selectedCategoryId of
                Nothing ->
                    viewLanding model

                Just _ ->
                    viewPerCategory model
        , dialog = Dialog.none
        }


viewLanding : Model -> Element Msg
viewLanding model =
    column [ width fill ]
        [ UI.ReloadableData.view (viewRecentPublications model) model.recentPublications ]


viewPerCategory : Model -> Element Msg
viewPerCategory model =
    column [ width fill ]
        [ UI.ReloadableData.view (viewRecentPublications model) model.recentPublications
        , UI.ReloadableData.view (viewPublications model) model.publications
        ]


viewRecentPublications : Model -> List Publication.MetaData -> Element Msg
viewRecentPublications model publications =
    column [ width fill ]
        [ Heading.heading 2 "Recently Read"
        , row [ width fill, height (px 250), Background.transparentLightBlack ]
            (publications |> List.map (publicationView model))
        ]


viewPublications : Model -> List Publication.MetaData -> Element Msg
viewPublications model publications =
    if List.isEmpty publications then
        text <| "No publications"

    else
        column [ width fill ]
            [ BreadCrumb.breadCrumb []
            , wrappedRow [ UI.padding 1, UI.spacing 1 ]
                (publications |> List.map (publicationView model))
            ]


publicationView : Model -> Publication.MetaData -> Element Msg
publicationView model publication =
    let
        url =
            Route.publicationUrl publication.id

        noImage =
            ReloadableData.Success () Image.none
    in
    Card.bordered []
        { actions = []
        , content =
            [ link
                [ width fill
                , height fill
                ]
                { url = url
                , label =
                    UI.reloadableThumbnail
                        { title = publication.title
                        , image = Dict.get publication.id model.covers |> Maybe.withDefault noImage
                        }
                }
            , publicationActionView publication.id
            ]
        }


publicationActionView : Int -> Element Msg
publicationActionView publicationId =
    row
        [ alignRight
        , alignBottom
        , height shrink
        , htmlAttribute <| HA.style "position" "absolute"
        , htmlAttribute <| HA.style "bottom" "0"
        , UI.spacing -5
        , UI.padding -10
        ]
        [ Action.toElement <|
            Action.compact <|
                Action.link
                    { text = "Read"
                    , icon = Icon.read Icon.small
                    , url = Route.readUrl publicationId
                    , onClick = LinkClicked
                    }
        ]



-- UPDATE


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked url ->
            ( model
            , Nav.pushUrl key url
            )

        CategorySelected selectedCategoryId ->
            selectCategory selectedCategoryId model

        GetPublicationCompleted publications ->
            ( { model
                | publications = publications
                , covers =
                    publications
                        |> ReloadableData.toMaybe
                        |> Maybe.withDefault []
                        |> List.filterMap
                            (\pub ->
                                if Thumbnail.hasThumbnail pub.thumbnail then
                                    Just ( pub.id, ReloadableData.Loading () )

                                else
                                    Nothing
                            )
                        |> Dict.fromList
              }
            , publications
                |> ReloadableData.toMaybe
                |> Maybe.withDefault []
                |> List.map
                    (\pub ->
                        if Thumbnail.hasThumbnail pub.thumbnail then
                            Publication.downloadCover
                                { publicationId = pub.id
                                , msg = CoverDownloaded pub.id
                                }

                        else
                            Cmd.none
                    )
                |> Cmd.batch
            )

        CoverDownloaded publicationId data ->
            ( { model
                | covers =
                    model.covers
                        |> Dict.insert publicationId data
              }
            , Cmd.none
            )

        GetRecentPublicationCompleted data ->
            ( { model | recentPublications = data }, Cmd.none )


updateRecentPublications : Model -> ( Model, Cmd Msg )
updateRecentPublications model =
    ( { model | recentPublications = ReloadableData.loading model.recentPublications }
    , Publication.getRecent GetRecentPublicationCompleted
    )


selectCategory : Maybe Int -> Model -> ( Model, Cmd Msg )
selectCategory selectedCategoryId model =
    ( { model
        | selectedCategoryId = selectedCategoryId
        , publications =
            case selectedCategoryId of
                Nothing ->
                    ReloadableData.NotAsked ()

                Just _ ->
                    ReloadableData.loading model.publications
      }
    , selectedCategoryId
        |> Maybe.map
            (\id ->
                Publication.listByCategory
                    { categoryId = id
                    , msg = GetPublicationCompleted
                    }
            )
        |> Maybe.withDefault Cmd.none
    )


selectedItem : Maybe Int -> UI.Nav.Side.SelectedItem
selectedItem selectedCategoryId =
    case selectedCategoryId of
        Just id ->
            UI.Nav.Side.CategoryId id

        Nothing ->
            UI.Nav.Side.NoSelection
