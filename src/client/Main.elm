module Main exposing (main)

-- import Route exposing (Route)

import Browser
import Browser.Navigation as Nav
import Entity.Category exposing (Category)
import Html exposing (..)
import Page.Home as HomePage
import Page.Problem as ProblemPage
import Page.Publication as PublicationPage
import Page.Read as ReadPage
import ReloadableData exposing (ReloadableWebData)
import Set
import Tree exposing (Tree)
import Url
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s, top)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


type alias Model =
    { key : Nav.Key
    , page : Page
    , favoriteCategories : ReloadableWebData () (List Category)
    }


type Page
    = Home HomePage.Model
    | BrowseByCategory
    | BrowseByMediaType
    | Publication PublicationPage.Model
    | Read ReadPage.Model
    | Problem String


type Msg
    = NoOp
    | UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | HomeMsg HomePage.Msg
    | PublicationMsg PublicationPage.Msg
    | ReadMsg ReadPage.Msg
    | LoadFavoriteCompleted (ReloadableWebData () (List Category))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( model, cmd ) =
            stepUrl url
                { key = key
                , page = Home HomePage.initialModel
                , favoriteCategories = ReloadableData.Loading ()
                }
    in
    ( model
    , Cmd.batch [ cmd, Entity.Category.favorite LoadFavoriteCompleted ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlChanged url ->
            stepUrl url model

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        HomeMsg homeMsg ->
            case model.page of
                Home homeModel ->
                    let
                        ( newHomeModel, cmds ) =
                            HomePage.update model.key homeMsg homeModel
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
                            PublicationPage.update model.key pubMsg pubModel
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

        LoadFavoriteCompleted data ->
            ( { model | favoriteCategories = data }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    case model.page of
        Home homeModel ->
            HomePage.view model.key model.favoriteCategories homeModel
                |> mapPage HomeMsg

        Publication publicationModel ->
            PublicationPage.view model.favoriteCategories publicationModel
                |> mapPage PublicationMsg

        Read readModel ->
            ReadPage.view readModel
                |> mapPage ReadMsg

        Problem text ->
            ProblemPage.view text

        BrowseByMediaType ->
            { title = "Pustaka - Media Type", body = [] }

        BrowseByCategory ->
            { title = "Pustaka - Category", body = [] }


mapPage : (a -> b) -> Browser.Document a -> Browser.Document b
mapPage f page =
    { title = page.title
    , body = List.map (Html.map f) page.body
    }


stepUrl : Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl url model =
    let
        parser =
            oneOf
                [ route (s "app") (stepHome model (HomePage.init []))
                , route (s "app" </> s "category" </> int)
                    (\categoryId ->
                        case model.page of
                            Home homeModel ->
                                stepHome model (HomePage.selectCategories (Set.fromList [ categoryId ]) homeModel)

                            _ ->
                                stepHome model (HomePage.selectCategories (Set.fromList [ categoryId ]) HomePage.initialModel)
                    )
                , route (s "app" </> s "media-types")
                    (stepBrowseByMediaType model)
                , route (s "app" </> s "categories")
                    (stepBrowseByCategory model)
                , route (s "app" </> s "pub" </> int)
                    (\pubId -> stepPublication model (PublicationPage.init pubId))
                , route (s "app" </> s "read" </> int)
                    (\pubId -> stepRead model (ReadPage.init pubId))
                ]
    in
    case Parser.parse parser url of
        Just answer ->
            answer

        Nothing ->
            ( { model | page = Problem "Not Found" }, Cmd.none )


route : Parser a b -> a -> Parser (b -> c) c
route parser handler =
    Parser.map handler parser


stepHome : Model -> ( HomePage.Model, Cmd HomePage.Msg ) -> ( Model, Cmd Msg )
stepHome model ( homeModel, cmds ) =
    ( { model | page = Home homeModel }
    , Cmd.map HomeMsg cmds
    )


stepBrowseByCategory : Model -> ( Model, Cmd Msg )
stepBrowseByCategory model =
    ( { model | page = BrowseByCategory }, Cmd.none )


stepBrowseByMediaType : Model -> ( Model, Cmd Msg )
stepBrowseByMediaType model =
    ( { model | page = BrowseByMediaType }, Cmd.none )


stepPublication : Model -> ( PublicationPage.Model, Cmd PublicationPage.Msg ) -> ( Model, Cmd Msg )
stepPublication model ( pubModel, cmds ) =
    ( { model | page = Publication pubModel }, Cmd.map PublicationMsg cmds )


stepRead : Model -> ( ReadPage.Model, Cmd ReadPage.Msg ) -> ( Model, Cmd Msg )
stepRead model ( readModel, cmds ) =
    ( { model | page = Read readModel }, Cmd.map ReadMsg cmds )
