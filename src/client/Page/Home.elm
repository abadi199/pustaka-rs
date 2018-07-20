module Page.Home
    exposing
        ( Model
        , Msg(..)
        , init
        , initialModel
        , selectCategories
        , update
        , view
        )

import Browser
import Browser.Navigation as Navigation
import Entity.Category exposing (Category)
import Entity.Publication as Publication
import Html exposing (..)
import Html.Attributes exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set exposing (Set)
import Tree exposing (Tree)
import UI.Card
import UI.Error
import UI.Layout.SideNav
import UI.Loading
import UI.Menu


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
    , publications = ReloadableData.Loading ()
    }


type Msg
    = CategoryClicked Int
    | CategorySelected (List Int)
    | GetPublicationCompleted (ReloadableWebData () (List Publication.MetaData))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CategoryClicked id ->
            ( model
            , Cmd.none
              -- , Navigation.pushUrl model.key <| Route.categoryUrl id
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
        , publications = ReloadableData.loading model.publications
      }
    , selectedCategoryIds
        |> Set.toList
        |> List.head
        |> Debug.log "categoryId"
        |> Maybe.map (\id -> Publication.listByCategory id GetPublicationCompleted)
        |> Maybe.withDefault Cmd.none
    )


view : ReloadableWebData () (Tree Category) -> Model -> Browser.Document Msg
view categories model =
    { title = "Pustaka - Main"
    , body =
        [ UI.Layout.SideNav.view CategoryClicked
            model.selectedCategoryIds
            categories
            (mainSection model.publications)
        ]
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
                [ UI.Error.view <| Debug.toString error ]

            FailureWithData error publications ->
                [ publicationsView publications, UI.Error.view <| Debug.toString error ]
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
        [ style "display" "flex"
        , style "align-items" "center"
        , style "justify-content" "center"
        , style "max-height" "100%"
        ]
        [ text "N/A" ]
