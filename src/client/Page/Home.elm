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
import Css exposing (..)
import Entity.Category exposing (Category)
import Entity.Publication as Publication
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set exposing (Set)
import Tree exposing (Tree)
import UI.Card
import UI.Error
import UI.Layout
import UI.Loading
import UI.Menu
import UI.Nav.Side
import UI.Parts.Search


type alias Model =
    { selectedCategoryId : Maybe Int
    , publications : ReloadableWebData () (List Publication.MetaData)
    }


init : Maybe Int -> ( Model, Cmd Msg )
init selectedCategoryId =
    selectCategory selectedCategoryId initialModel


initialModel : Model
initialModel =
    { selectedCategoryId = Nothing
    , publications = ReloadableData.NotAsked ()
    }


type Msg
    = NoOp
    | MenuItemClicked String
    | CategorySelected (Maybe Int)
    | GetPublicationCompleted (ReloadableWebData () (List Publication.MetaData))


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MenuItemClicked url ->
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


view : Nav.Key -> ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view key categories model =
    UI.Layout.withSideNav
        { title = "Pustaka - Main"
        , sideNav =
            categories
                |> UI.Nav.Side.view MenuItemClicked (selectedItem model.selectedCategoryId)
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp))
        , content = [ mainSection model.publications ]
        }


mainSection : ReloadableWebData () (List Publication.MetaData) -> Html Msg
mainSection data =
    div []
        (case data of
            NotAsked _ ->
                []

            Loading _ ->
                [ UI.Loading.view ]

            Reloading publications ->
                [ UI.Loading.view, publicationsView publications ]

            Success publications ->
                [ publicationsView publications ]

            Failure error _ ->
                [ UI.Error.view "Error" ]

            FailureWithData error publications ->
                [ publicationsView publications, UI.Error.view "Error" ]
        )


publicationsView : List Publication.MetaData -> Html Msg
publicationsView publications =
    div [ style "display" "flex", style "flex-wrap" "wrap" ]
        (publications |> List.map publicationView)


publicationView : Publication.MetaData -> Html Msg
publicationView publication =
    UI.Card.view
        [ a [] [ text publication.title ]
        , a [ href <| Route.publicationUrl publication.id ]
            [ publication.thumbnail
                |> Maybe.map (\thumbnail -> img [ src thumbnail, style "max-width" "100px" ] [])
                |> Maybe.withDefault emptyThumbnail
            ]
        ]


emptyThumbnail : Html msg
emptyThumbnail =
    div
        [ css [ displayFlex, alignItems center, justifyContent center, maxHeight (pct 100) ]
        ]
        [ text "N/A" ]
