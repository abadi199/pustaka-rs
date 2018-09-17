module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Entity.Category exposing (Category)
import Html exposing (..)
import Page.ByCategory as ByCategoryPage
import Page.Home as HomePage
import Page.Problem as ProblemPage
import Page.Publication as PublicationPage
import Page.Read as ReadPage
import ReloadableData exposing (ReloadableWebData)
import Return
import Set
import Tree exposing (Tree)
import UI.Layout
import UI.Nav.Side
import UI.Parts.Search
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
    | ByCategory ByCategoryPage.Model
    | ByMediaType
    | Publication PublicationPage.Model
    | Read ReadPage.Model
    | Problem String


type Msg
    = NoOp
    | UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | LoadFavoriteCompleted (ReloadableWebData () (List Category))
    | PageMsg PageMsg


type PageMsg
    = HomeMsg HomePage.Msg
    | ByCategoryMsg ByCategoryPage.Msg
    | PublicationMsg PublicationPage.Msg
    | ReadMsg ReadPage.Msg


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

        LoadFavoriteCompleted data ->
            ( { model | favoriteCategories = data }, Cmd.none )

        UrlChanged url ->
            stepUrl url model

        LinkClicked url ->
            gotoUrl model url

        PageMsg pageMsg ->
            pageUpdate pageMsg model


pageUpdate : PageMsg -> Model -> ( Model, Cmd Msg )
pageUpdate msg model =
    case ( msg, model.page ) of
        ( HomeMsg pageMsg, Home pageModel ) ->
            HomePage.update model.key pageMsg pageModel
                |> Return.mapBoth (PageMsg << HomeMsg) (updatePage model Home)

        ( ByCategoryMsg pageMsg, ByCategory pageModel ) ->
            ByCategoryPage.update model.key pageMsg pageModel
                |> Return.mapBoth (PageMsg << ByCategoryMsg) (updatePage model ByCategory)

        ( PublicationMsg pageMsg, Publication pageModel ) ->
            PublicationPage.update model.key pageMsg pageModel
                |> Return.mapBoth (PageMsg << PublicationMsg) (updatePage model Publication)

        ( ReadMsg pageMsg, Read pageModel ) ->
            ReadPage.update pageMsg pageModel
                |> Return.mapBoth (PageMsg << ReadMsg) (updatePage model Read)

        _ ->
            ( model, Cmd.none )


gotoUrl : Model -> Browser.UrlRequest -> ( Model, Cmd Msg )
gotoUrl model url =
    case url of
        Browser.Internal internalUrl ->
            ( model, Nav.pushUrl model.key (Url.toString internalUrl) )

        Browser.External externalUrl ->
            ( model, Nav.load externalUrl )


updatePage : Model -> (a -> Page) -> a -> Model
updatePage model page pageModel =
    { model | page = page pageModel }


view : Model -> Browser.Document Msg
view model =
    case model.page of
        Home homeModel ->
            HomePage.view model.key model.favoriteCategories homeModel
                |> mapPage (PageMsg << HomeMsg)

        Publication publicationModel ->
            PublicationPage.view model.favoriteCategories publicationModel
                |> mapPage (PageMsg << PublicationMsg)

        Read readModel ->
            ReadPage.view readModel
                |> mapPage (PageMsg << ReadMsg)

        Problem text ->
            ProblemPage.view text

        ByMediaType ->
            UI.Layout.withSideNav
                { title = "Pustaka - Browse By Media Type"
                , sideNav =
                    model.favoriteCategories
                        |> UI.Nav.Side.view (always NoOp) UI.Nav.Side.BrowseByMediaType
                        |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp))
                , content = []
                }

        ByCategory byCategoryModel ->
            ByCategoryPage.view model.key model.favoriteCategories byCategoryModel
                |> mapPage (PageMsg << ByCategoryMsg)


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
                [ route (s "app") (stepHome model (HomePage.init Nothing))
                , route (s "app" </> s "category" </> int)
                    (\categoryId ->
                        case model.page of
                            Home homeModel ->
                                stepHome model (HomePage.selectCategory (Just categoryId) homeModel)

                            _ ->
                                stepHome model (HomePage.selectCategory (Just categoryId) HomePage.initialModel)
                    )
                , route (s "app" </> s "media-types")
                    (stepBrowseByMediaType model)
                , route (s "app" </> s "categories")
                    (stepByCategory model (ByCategoryPage.init Nothing))
                , route (s "app" </> s "categories" </> int)
                    (\categoryId -> stepByCategory model (ByCategoryPage.init (Just categoryId)))
                , route (s "app" </> s "pub" </> int)
                    (\pubId -> stepPublication model (PublicationPage.init pubId))
                , route (s "app" </> s "read" </> int)
                    (\pubId -> stepRead model (ReadPage.init pubId Nothing))
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
    , Cmd.map (PageMsg << HomeMsg) cmds
    )


stepByCategory : Model -> ( ByCategoryPage.Model, Cmd ByCategoryPage.Msg ) -> ( Model, Cmd Msg )
stepByCategory model ( byCategoryModel, cmds ) =
    ( { model | page = ByCategory byCategoryModel }
    , Cmd.map (PageMsg << ByCategoryMsg) cmds
    )


stepBrowseByMediaType : Model -> ( Model, Cmd Msg )
stepBrowseByMediaType model =
    ( { model | page = ByMediaType }, Cmd.none )


stepPublication : Model -> ( PublicationPage.Model, Cmd PublicationPage.Msg ) -> ( Model, Cmd Msg )
stepPublication model ( pubModel, cmds ) =
    ( { model | page = Publication pubModel }
    , Cmd.map (PageMsg << PublicationMsg) cmds
    )


stepRead : Model -> ( ReadPage.Model, Cmd ReadPage.Msg ) -> ( Model, Cmd Msg )
stepRead model ( readModel, cmds ) =
    ( { model | page = Read readModel }
    , Cmd.map (PageMsg << ReadMsg) cmds
    )
