module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , initialModel
    , selectCategories
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
    { selectedCategoryIds : Set Int
    , publications : ReloadableWebData () (List Publication.MetaData)
    }


init : List Int -> ( Model, Cmd Msg )
init categoryIds =
    let
        selectedCategoryIds =
            Set.fromList categoryIds
    in
    selectCategories selectedCategoryIds initialModel


initialModel : Model
initialModel =
    { selectedCategoryIds = Set.fromList []
    , publications = ReloadableData.NotAsked ()
    }


type Msg
    = NoOp
    | MenuItemClicked String
    | CategorySelected (List Int)
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

        CategorySelected ids ->
            let
                selectedCategoryIds =
                    Set.fromList ids
            in
            selectCategories selectedCategoryIds model

        GetPublicationCompleted publications ->
            ( { model | publications = publications }
            , Cmd.none
            )


selectCategories : Set Int -> Model -> ( Model, Cmd Msg )
selectCategories selectedCategoryIds model =
    ( { model
        | selectedCategoryIds = selectedCategoryIds
        , publications =
            if Set.isEmpty selectedCategoryIds then
                ReloadableData.NotAsked ()

            else
                ReloadableData.loading model.publications
      }
    , selectedCategoryIds
        |> Set.toList
        |> List.head
        |> Maybe.map (\id -> Publication.listByCategory id GetPublicationCompleted)
        |> Maybe.withDefault Cmd.none
    )


view : Nav.Key -> ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view key categories model =
    UI.Layout.withSideNav
        { title = "Pustaka - Main"
        , sideNav =
            categories
                |> UI.Nav.Side.view MenuItemClicked model.selectedCategoryIds
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
