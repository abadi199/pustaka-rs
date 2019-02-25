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
import Element as E exposing (..)
import Entity.Category exposing (Category)
import Entity.Publication as Publication
import Html.Attributes as HA
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set exposing (Set)
import Tree exposing (Tree)
import UI.Action as Action
import UI.Card as Card
import UI.Error
import UI.Icon as Icon
import UI.Layout
import UI.Loading
import UI.Menu
import UI.Nav.Side
import UI.Parts.BreadCrumb as BreadCrumb
import UI.Parts.Search
import UI.Poster as UI
import UI.Spacing as UI



-- MODEL


type alias Model =
    { selectedCategoryId : Maybe Int
    , publications : ReloadableWebData () (List Publication.MetaData)
    , searchText : String
    }


init : Maybe Int -> ( Model, Cmd Msg )
init selectedCategoryId =
    selectCategory selectedCategoryId initialModel


initialModel : Model
initialModel =
    { selectedCategoryId = Nothing
    , publications = ReloadableData.NotAsked ()
    , searchText = ""
    }



-- MESSAGE


type Msg
    = NoOp
    | LinkClicked String
    | CategorySelected (Maybe Int)
    | GetPublicationCompleted (ReloadableWebData () (List Publication.MetaData))



-- VIEw


view : Nav.Key -> ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view key categories model =
    UI.Layout.withSideNav
        { title = "Pustaka - Main"
        , sideNav =
            categories
                |> UI.Nav.Side.view LinkClicked (selectedItem model.selectedCategoryId)
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp) model.searchText)
        , content = mainSection model.publications
        }


mainSection : ReloadableWebData () (List Publication.MetaData) -> Element Msg
mainSection data =
    el []
        (case data of
            NotAsked _ ->
                E.none

            Loading _ ->
                UI.Loading.view

            Reloading _ publications ->
                el [ inFront UI.Loading.view ] (publicationsView publications)

            Success _ publications ->
                publicationsView publications

            Failure error _ ->
                UI.Error.view <| Debug.toString error

            FailureWithData error _ publications ->
                el [ inFront <| UI.Error.view <| Debug.toString error ] (publicationsView publications)
        )


publicationsView : List Publication.MetaData -> Element Msg
publicationsView publications =
    column [ width fill ]
        [ BreadCrumb.breadCrumb []
        , wrappedRow [ UI.padding 1, UI.spacing 1 ]
            (publications |> List.map publicationView)
        ]


publicationView : Publication.MetaData -> Element Msg
publicationView publication =
    let
        url =
            Route.publicationUrl publication.id
    in
    Card.bordered []
        [ link
            [ width fill
            , height fill
            ]
            { url = url
            , label = UI.thumbnail publication.title publication.thumbnail
            }
        , publicationActionView publication.id
        ]


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
                    , icon = Icon.read
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
            ( { model | publications = publications }
            , Cmd.none
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
        |> Maybe.map (\id -> Publication.listByCategory id GetPublicationCompleted)
        |> Maybe.withDefault Cmd.none
    )


selectedItem : Maybe Int -> UI.Nav.Side.SelectedItem
selectedItem selectedCategoryId =
    case selectedCategoryId of
        Just id ->
            UI.Nav.Side.CategoryId id

        Nothing ->
            UI.Nav.Side.NoSelection
