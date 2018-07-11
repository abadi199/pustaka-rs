module Main exposing (main)

import Browser
import Entity.Category exposing (Category)
import Html exposing (..)
import Page.Home as HomePage
import Page.Problem as ProblemPage
import Page.Publication as PublicationPage
import Page.Read as ReadPage
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
    , categories : ReloadableWebData () (Tree Category)
    }


initialModel : Model
initialModel =
    { route = Route.Home
    , page = Home HomePage.initialModel
    , categories = ReloadableData.Loading ()
    }


type Page
    = Home HomePage.Model
    | Publication PublicationPage.Model
    | Read ReadPage.Model
    | Problem String


type Msg
    = NoOp
    | GetCategoriesCompleted (ReloadableWebData () (Tree Category))
    | RouteChanged Route
    | HomeMsg HomePage.Msg
    | PublicationMsg PublicationPage.Msg
    | ReadMsg ReadPage.Msg


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

        HomeMsg homeMsg ->
            case model.page of
                Home homeModel ->
                    let
                        ( newHomeModel, cmds ) =
                            HomePage.update homeMsg homeModel
                    in
                    ( { model | page = Home newHomeModel }
                    , cmds |> Cmd.map HomeMsg
                    )

                _ ->
                    ( model, Cmd.none )

        PublicationMsg pubMsg ->
            case model.page of
                Publication pubModel ->
                    let
                        ( newPubModel, cmds ) =
                            PublicationPage.update pubMsg pubModel
                    in
                    ( { model | page = Publication newPubModel }
                    , cmds |> Cmd.map PublicationMsg
                    )

                _ ->
                    ( model, Cmd.none )

        ReadMsg readMsg ->
            case model.page of
                Read readModel ->
                    let
                        ( newReadModel, cmds ) =
                            ReadPage.update readMsg readModel
                    in
                    ( { model | page = Read newReadModel }, cmds |> Cmd.map ReadMsg )

                _ ->
                    ( model, Cmd.none )


check : Model -> Cmd Msg -> ( Model, Cmd Msg )
check model cmd =
    case model.route of
        Route.Home ->
            let
                ( initialHomeModel, initialHomeCmd ) =
                    HomePage.init
            in
            ( { model | page = Home initialHomeModel }
            , Cmd.batch [ initialHomeCmd |> Cmd.map HomeMsg, cmd ]
            )

        Route.Category categoryIds ->
            let
                ( homeModel, homeCmd ) =
                    case model.page of
                        Home currentHomeModel ->
                            HomePage.update (HomePage.CategorySelected categoryIds) currentHomeModel

                        _ ->
                            HomePage.update (HomePage.CategorySelected categoryIds) HomePage.initialModel
            in
            ( { model | page = Home homeModel }
            , Cmd.batch [ homeCmd |> Cmd.map HomeMsg, cmd ]
            )

        Route.Publication publicationId ->
            let
                ( pubModel, pubCmd ) =
                    PublicationPage.init publicationId
            in
            ( { model | page = Publication pubModel }, pubCmd |> Cmd.map PublicationMsg )

        Route.Read publicationId ->
            let
                ( readModel, readCmd ) =
                    ReadPage.init publicationId
            in
            ( { model | page = Read readModel }, readCmd |> Cmd.map ReadMsg )

        Route.NotFound text ->
            ( { model | page = Problem "404" }, cmd )


view : Model -> Browser.Page Msg
view model =
    case model.page of
        Home homeModel ->
            HomePage.view model.categories homeModel
                |> mapPage HomeMsg

        Publication publicationModel ->
            PublicationPage.view model.categories publicationModel
                |> mapPage PublicationMsg

        Read readModel ->
            ReadPage.view readModel
                |> mapPage ReadMsg

        Problem text ->
            ProblemPage.view text


mapPage : (a -> b) -> Browser.Page a -> Browser.Page b
mapPage f page =
    { title = page.title
    , body = List.map (Html.map f) page.body
    }
