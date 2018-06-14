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
    | MainMsg Page.Main.Msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : Browser.Env () -> ( Model, Cmd Msg )
init env =
    check (initialModel (Route.fromUrl env.url))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RouteChanged route ->
            check { model | route = route }

        MainMsg mainMsg ->
            case model.page of
                Main mainModel ->
                    let
                        ( newMainModel, cmds ) =
                            Page.Main.update mainMsg mainModel
                    in
                    ( { model | page = Main newMainModel }, cmds |> Cmd.map MainMsg )

                _ ->
                    ( model, Cmd.none )


check : Model -> ( Model, Cmd Msg )
check model =
    case model.route of
        Route.Home ->
            let
                ( initialMainModel, initialMainCmd ) =
                    Page.Main.init
            in
            ( { model | page = Main initialMainModel }
            , initialMainCmd |> Cmd.map MainMsg
            )

        Category categoryId ->
            ( { model | page = Problem "Category Page not implemented yet" }, Cmd.none )

        NotFound text ->
            ( { model | page = Problem "404" }, Cmd.none )


view : Model -> Browser.Page Msg
view model =
    case model.page of
        Main mainModel ->
            Page.Main.view mainModel
                |> mapPage MainMsg

        Problem text ->
            Page.Problem.view text


mapPage : (a -> b) -> Browser.Page a -> Browser.Page b
mapPage f page =
    { title = page.title
    , body = List.map (Html.map f) page.body
    }
