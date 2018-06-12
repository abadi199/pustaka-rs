module Main exposing (main)

import Browser
import Entity.Category
import Html exposing (..)
import Page.Main
import Page.Problem
import Route exposing (Route(..))
import Url


main : Program () Model Msg
main =
    Browser.fullscreen
        { init = init
        , onNavigation = Just onNavigation
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


onNavigation : Url.Url -> Msg
onNavigation url =
    RouteChanged (Route.fromUrl url)


type alias Model =
    { route : Route.Route
    , page : Page
    }


initialModel : Route.Route -> Model
initialModel route =
    { route = route
    , page = Main Page.Main.initialModel
    }


type Page
    = Main Page.Main.Model
    | Problem String


type Msg
    = NoOp
    | RouteChanged Route


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : Browser.Env () -> ( Model, Cmd Msg )
init env =
    check (initialModel (Route.fromUrl env.url))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "" msg
    in
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RouteChanged route ->
            check { model | route = route }


check : Model -> ( Model, Cmd Msg )
check model =
    case model.route of
        Route.Home ->
            ( { model | page = Main Page.Main.initialModel }, Cmd.none )

        Category categoryId ->
            ( { model | page = Problem "Category Page not implemented yet" }, Cmd.none )

        NotFound text ->
            ( { model | page = Problem "404" }, Cmd.none )


view : Model -> Browser.Page Msg
view model =
    case model.page of
        Main mainModel ->
            Page.Main.view mainModel

        Problem text ->
            Page.Problem.view text
