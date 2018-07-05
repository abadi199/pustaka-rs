module Page.Publication
    exposing
        ( Model
        , Msg
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
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set
import String
import Tree exposing (Tree)
import UI.Layout.SideNav
import UI.ReloadableData


view : ReloadableWebData () (Tree Category) -> Model -> Browser.Page Msg
view categoryData model =
    { title = "Pustaka - Publication"
    , body =
        [ UI.Layout.SideNav.view CategoryClicked
            (Set.fromList [])
            categoryData
            (div []
                (UI.ReloadableData.view
                    publicationView
                    model.publication
                )
            )
        ]
    }


publicationView : Publication -> Html Msg
publicationView publication =
    text <| Debug.toString publication


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CategoryClicked id ->
            ( model, Navigation.pushUrl <| Route.categoryUrl id )

        GetPublicationCompleted data ->
            ( { model | publication = data }, Cmd.none )


type alias Model =
    { publication : ReloadableWebData Int Publication }


init : Int -> ( Model, Cmd Msg )
init publicationId =
    ( initialModel publicationId
    , Entity.Publication.get publicationId GetPublicationCompleted
    )


initialModel : Int -> Model
initialModel publicationId =
    { publication = ReloadableData.Loading publicationId }


type Msg
    = CategoryClicked Int
    | GetPublicationCompleted (ReloadableWebData Int Publication)
