module Main exposing (main)

import Browser
import Entity.Category exposing (Category)
import Html exposing (..)
import Page.Main
import Page.Problem
import ReloadableData exposing (ReloadableWebData)
import Route exposing (Route)
import Set
import Tree exposing (Tree)
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
    , categories : ReloadableWebData (Tree Category)
    }


initialModel : Model
initialModel =
    { route = Route.Home
    , page = Main Page.Main.initialModel
    , categories = ReloadableData.Loading
    }


type Page
    = Main Page.Main.Model
    | Problem String


type Msg
    = NoOp
    | GetCategoriesCompleted (ReloadableWebData (Tree Category))
    | RouteChanged Route
    | MainMsg Page.Main.Msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : Browser.Env () -> ( Model, Cmd Msg )
init env =
    let
        ( model, cmds ) =
            update (RouteChanged (Route.fromUrl env.url)) initialModel
    in
    ( model
    , Cmd.batch
        [ cmds
        , Entity.Category.list GetCategoriesCompleted
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            check model Cmd.none

        GetCategoriesCompleted data ->
            check { model | categories = data } Cmd.none

        RouteChanged route ->
            check { model | route = route } Cmd.none

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


check : Model -> Cmd Msg -> ( Model, Cmd Msg )
check model cmd =
    case model.route of
        Route.Home ->
            let
                ( initialMainModel, initialMainCmd ) =
                    Page.Main.init
            in
            ( { model | page = Main initialMainModel }
            , Cmd.batch [ initialMainCmd |> Cmd.map MainMsg, cmd ]
            )

        Route.Category categoryIds ->
            let
                ( mainModel, mainCmd ) =
                    case model.page of
                        Main currentMainModel ->
                            Page.Main.update (Page.Main.CategorySelected categoryIds) currentMainModel

                        _ ->
                            Page.Main.init
            in
            ( { model | page = Main mainModel }
            , Cmd.batch [ mainCmd |> Cmd.map MainMsg, cmd ]
            )

        Route.NotFound text ->
            ( { model | page = Problem "404" }, cmd )


view : Model -> Browser.Page Msg
view model =
    case model.page of
        Main mainModel ->
            Page.Main.view model.categories mainModel
                |> mapPage MainMsg

        Problem text ->
            Page.Problem.view text


mapPage : (a -> b) -> Browser.Page a -> Browser.Page b
mapPage f page =
    { title = page.title
    , body = List.map (Html.map f) page.body
    }
