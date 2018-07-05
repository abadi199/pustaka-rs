module Page.Home
    exposing
        ( Model
        , Msg(..)
        , init
        , initialModel
        , update
        , view
        )

import Browser
import Browser.Navigation as Navigation
import Entity.Category exposing (Category)
import Entity.Publication exposing (Publication)
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
    , publications : ReloadableWebData () (List Publication)
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.none
    )


initialModel : Model
initialModel =
    { selectedCategoryIds = Set.empty
    , publications = ReloadableData.NotAsked ()
    }


type Msg
    = CategoryClicked Int
    | CategorySelected (List Int)
    | GetPublicationCompleted (ReloadableWebData () (List Publication))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CategoryClicked id ->
            ( model, Navigation.pushUrl <| Route.categoryUrl id )

        CategorySelected ids ->
            let
                selectedCategoryIds =
                    Set.fromList ids
            in
            ( { model
                | selectedCategoryIds = selectedCategoryIds
                , publications = ReloadableData.loading model.publications
              }
            , selectedCategoryIds
                |> Set.toList
                |> List.head
                |> Maybe.map (\id -> Entity.Publication.listByCategory id GetPublicationCompleted)
                |> Maybe.withDefault Cmd.none
            )

        GetPublicationCompleted publications ->
            ( { model | publications = publications }
            , Cmd.none
            )


view : ReloadableWebData () (Tree Category) -> Model -> Browser.Page Msg
view categories model =
    { title = "Pustaka - Main"
    , body =
        [ UI.Layout.SideNav.view CategoryClicked
            model.selectedCategoryIds
            categories
            (mainSection model.publications)
        ]
    }


mainSection : ReloadableWebData () (List Publication) -> Html Msg
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


publicationsView : List Publication -> Html Msg
publicationsView publications =
    div [ style "display" "flex", style "flex-wrap" "wrap" ]
        (publications |> List.map publicationView)


publicationView : Publication -> Html Msg
publicationView publication =
    UI.Card.view
        [ a [] [ text publication.title ]
        , a [ href <| "/pub/" ++ String.fromInt publication.id ]
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
