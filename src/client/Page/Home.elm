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
import Css exposing (..)
import Dict exposing (Dict)
import Entity.Category as Category exposing (Category)
import Entity.Image as Image exposing (Image)
import Entity.Publication as Publication
import Entity.Thumbnail as Thumbnail
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import UI.Action as Action
import UI.Background as Background
import UI.Card as Card
import UI.Css.Grid as Grid
import UI.Heading as Heading
import UI.Icon as Icon
import UI.Layout
import UI.Nav.Side
import UI.Parts.Dialog as Dialog
import UI.Parts.Search
import UI.Poster as UI
import UI.ReloadableData
import UI.Spacing as UI



-- MODEL


type alias Model =
    { selectedCategoryId : Maybe (ReloadableWebData Int Category)
    , publications : ReloadableWebData () (List Publication.MetaData)
    , categories : ReloadableWebData () (List Category)
    , recentlyAddedPublications : Dict Int (ReloadableWebData () (List Publication.MetaData))
    , recentlyReadPublications : ReloadableWebData () (List Publication.MetaData)
    , covers : Dict Int (ReloadableWebData () Image)
    , searchText : String
    }


init : Maybe Int -> ( Model, Cmd Msg )
init selectedCategoryId =
    selectCategory selectedCategoryId initialModel
        |> Cmd.andThen updateRecentlyReadPublications
        |> Cmd.andThen getCategories


initialModel : Model
initialModel =
    { selectedCategoryId = Nothing
    , publications = ReloadableData.NotAsked ()
    , categories = ReloadableData.NotAsked ()
    , recentlyAddedPublications = Dict.empty
    , recentlyReadPublications = ReloadableData.NotAsked ()
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
    | GetRecentlyReadPublicationCompleted (ReloadableWebData () (List Publication.MetaData))
    | GetCategoriesCompleted (ReloadableWebData () (List Category))
    | GetRecentlyAddedPublicationCompleted Int (ReloadableWebData () (List Publication.MetaData))
    | GetCategoryCompleted (ReloadableWebData Int Category)



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


viewLanding : Model -> Html Msg
viewLanding model =
    div [ css [ Grid.display, Grid.rowGap 20, Grid.templateColumns [ "100%" ] ] ]
        (UI.ReloadableData.view (viewRecentPublications model) model.recentlyReadPublications
            :: (model.categories
                    |> ReloadableData.expand
                    |> List.map (UI.ReloadableData.view (viewRecentlyAddedByCategory model))
               )
        )


viewRecentlyAddedByCategory : Model -> Category -> Html Msg
viewRecentlyAddedByCategory model category =
    let
        maybeData : Maybe (ReloadableWebData () (List Publication.MetaData))
        maybeData =
            model.recentlyAddedPublications
                |> Dict.get category.id
    in
    case maybeData of
        Just data ->
            UI.ReloadableData.view (viewPublicationsRow category.name model) data

        Nothing ->
            text ""


viewPerCategory : Model -> Html Msg
viewPerCategory model =
    div
        [ css [ width (pct 100) ] ]
        [ model.selectedCategoryId
            |> Maybe.andThen ReloadableData.toMaybe
            |> Maybe.map (\category -> Heading.heading 2 category.name)
            |> Maybe.withDefault (text "")
        , UI.ReloadableData.view (viewPublications model) model.publications
        ]


viewRecentPublications : Model -> List Publication.MetaData -> Html Msg
viewRecentPublications model publications =
    div
        [ css
            [ width (pct 100)
            , Background.transparentMediumBlack
            , UI.padding UI.Small
            , UI.marginBottom UI.Large
            ]
        ]
        [ viewPublicationsRow "Continue Reading" model publications ]


viewPublicationsRow : String -> Model -> List Publication.MetaData -> Html Msg
viewPublicationsRow title model publications =
    if List.isEmpty publications then
        text ""

    else
        div
            [ css
                [ width (pct 100)
                , UI.padding UI.Medium
                ]
            ]
            [ Heading.heading 2 title
            , div
                [ css
                    [ displayFlex
                    , flexDirection row
                    , overflowX auto
                    , UI.paddingTop UI.Small
                    ]
                ]
                (publications |> List.map (publicationView model))
            ]


viewPublications : Model -> List Publication.MetaData -> Html Msg
viewPublications model publications =
    if List.isEmpty publications then
        text <| "No publications"

    else
        div [ css [ width (pct 100) ] ]
            [ div
                [ css
                    [ UI.paddingEach { top = UI.Large, right = UI.Medium, bottom = UI.Medium, left = UI.Medium }
                    ]
                ]
                (publications |> List.map (publicationView model))
            ]


publicationView : Model -> Publication.MetaData -> Html Msg
publicationView model publication =
    let
        url =
            Route.publicationUrl publication.id

        noImage =
            ReloadableData.Success () Image.none
    in
    Card.bordered [ css [ UI.padding UI.Small, position relative ] ]
        { actions = []
        , content =
            [ a
                [ css
                    [ width (pct 100)
                    , height (pct 100)
                    ]
                , HA.href url
                ]
                [ UI.reloadableThumbnail
                    { title = publication.title
                    , image = Dict.get publication.id model.covers |> Maybe.withDefault noImage
                    }
                ]
            , publicationActionView publication.id
            ]
        }


publicationActionView : Int -> Html Msg
publicationActionView publicationId =
    div
        [ css
            [ position absolute
            , bottom (px 0)
            , right (px 10)
            , UI.padding UI.Small
            ]
        ]
        [ Action.toHtml <|
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
            , downloadCovers publications
            )

        CoverDownloaded publicationId data ->
            ( { model
                | covers =
                    model.covers
                        |> Dict.insert publicationId data
              }
            , Cmd.none
            )

        GetRecentlyReadPublicationCompleted data ->
            ( { model | recentlyReadPublications = data }
            , downloadCovers data
            )

        GetCategoriesCompleted data ->
            ( { model | categories = data }
            , data
                |> ReloadableData.toMaybe
                |> Maybe.withDefault []
                |> List.map
                    (\category ->
                        Publication.getRecentlyAdded
                            { count = 10
                            , categoryId = category.id
                            , msg = GetRecentlyAddedPublicationCompleted category.id
                            }
                    )
                |> Cmd.batch
            )

        GetRecentlyAddedPublicationCompleted categoryId data ->
            ( { model
                | recentlyAddedPublications =
                    Dict.insert categoryId data model.recentlyAddedPublications
              }
            , downloadCovers data
            )

        GetCategoryCompleted data ->
            ( { model | selectedCategoryId = Just data }, Cmd.none )


downloadCovers : ReloadableWebData a (List Publication.MetaData) -> Cmd Msg
downloadCovers data =
    data
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


updateRecentlyReadPublications : Model -> ( Model, Cmd Msg )
updateRecentlyReadPublications model =
    ( { model | recentlyReadPublications = ReloadableData.loading model.recentlyReadPublications }
    , Publication.getRecentlyRead { count = 10, msg = GetRecentlyReadPublicationCompleted }
    )


getCategories : Model -> ( Model, Cmd Msg )
getCategories model =
    ( { model | categories = ReloadableData.loading model.categories }
    , Category.list GetCategoriesCompleted
    )


selectCategory : Maybe Int -> Model -> ( Model, Cmd Msg )
selectCategory selectedCategoryId model =
    ( { model
        | selectedCategoryId =
            selectedCategoryId
                |> Maybe.map ReloadableData.Loading
        , publications =
            selectedCategoryId
                |> Maybe.map (\_ -> ReloadableData.loading model.publications)
                |> Maybe.withDefault (ReloadableData.NotAsked ())
      }
    , selectedCategoryId
        |> Maybe.map
            (\id ->
                Cmd.batch
                    [ Publication.listByCategory
                        { categoryId = id
                        , msg = GetPublicationCompleted
                        }
                    , Category.get { categoryId = id, msg = GetCategoryCompleted }
                    ]
            )
        |> Maybe.withDefault Cmd.none
    )


selectedItem : Maybe (ReloadableWebData Int Category) -> UI.Nav.Side.SelectedItem
selectedItem selectedCategoryId =
    case selectedCategoryId |> Maybe.map ReloadableData.toInitial of
        Just id ->
            UI.Nav.Side.CategoryId id

        Nothing ->
            UI.Nav.Side.NoSelection
