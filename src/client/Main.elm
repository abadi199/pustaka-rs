module Main exposing (main)

import Assets exposing (Assets)
import Browser
import Browser.Dom exposing (Viewport)
import Browser.Events
import Browser.Navigation as Nav
import Entity.Category exposing (Category)
import Html
import Html.Styled as H exposing (..)
import Page.ByCategory as ByCategoryPage
import Page.Home as HomePage
import Page.Problem as ProblemPage
import Page.Publication as PublicationPage
import Page.Publication.Edit as PublicationEditPage
import Page.Read as ReadPage
import ReloadableData exposing (ReloadableWebData)
import Return
import Task
import UI.Layout
import Url
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s, top)


main : Program Assets Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    , favoriteCategories : ReloadableWebData () (List Category)
    , viewport : Viewport
    , assets : Assets
    , layoutState : UI.Layout.State Msg
    }


type Page
    = Home HomePage.Model
    | ByCategory ByCategoryPage.Model
    | ByMediaType
    | Publication PublicationPage.Model
    | PublicationEdit PublicationEditPage.Model
    | Read ReadPage.Model
    | Problem String


init : Assets -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init assets url key =
    let
        ( model, cmd ) =
            stepUrl url
                { key = key
                , page = Home HomePage.initialModel
                , favoriteCategories = ReloadableData.Loading ()
                , viewport =
                    { scene = { width = 0, height = 0 }
                    , viewport = { x = 0, y = 0, width = 0, height = 0 }
                    }
                , assets = assets
                , layoutState = UI.Layout.initialState
                }
    in
    ( model
    , Cmd.batch
        [ cmd
        , Entity.Category.favorite LoadFavoriteCompleted
        , Browser.Dom.getViewport |> Task.perform ViewPortUpdated
        ]
    )



-- MESSAGE


type Msg
    = NoOp
    | UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | LoadFavoriteCompleted (ReloadableWebData () (List Category))
    | PageMsg PageMsg
    | Resized
    | ViewPortUpdated Viewport


type PageMsg
    = HomeMsg HomePage.Msg
    | ByCategoryMsg ByCategoryPage.Msg
    | PublicationMsg PublicationPage.Msg
    | ReadMsg ReadPage.Msg
    | PublicationEditMsg PublicationEditPage.Msg



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\_ _ -> Resized)
        , case model.page of
            Read readModel ->
                ReadPage.subscriptions readModel
                    |> Sub.map (ReadMsg >> PageMsg)

            _ ->
                Sub.none
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.page of
        Home homeModel ->
            HomePage.view model homeModel
                |> mapPage (PageMsg << HomeMsg)

        Publication publicationModel ->
            PublicationPage.view model publicationModel
                |> mapPage (PageMsg << PublicationMsg)

        Read readModel ->
            ReadPage.view model.viewport readModel
                |> mapPage (PageMsg << ReadMsg)

        Problem text ->
            ProblemPage.view text

        ByMediaType ->
            UI.Layout.withNav
                { key = model.key
                , title = "Pustaka - Browse By Media Type"
                , assets = model.assets
                , content = text "WIP"
                , categories = model.favoriteCategories
                , state = model.layoutState
                , onStateChange = \_ _ -> NoOp
                }

        ByCategory byCategoryModel ->
            ByCategoryPage.view model byCategoryModel
                |> mapPage (PageMsg << ByCategoryMsg)

        PublicationEdit pageModel ->
            PublicationEditPage.view model pageModel
                |> mapPage (PageMsg << PublicationEditMsg)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Resized ->
            ( model
            , Browser.Dom.getViewport |> Task.perform ViewPortUpdated
            )

        ViewPortUpdated viewport ->
            ( { model | viewport = viewport }, Cmd.none )

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
            ReadPage.update model.key model.viewport pageMsg pageModel
                |> Return.mapBoth (PageMsg << ReadMsg) (updatePage model Read)

        ( PublicationEditMsg pageMsg, PublicationEdit pageModel ) ->
            PublicationEditPage.update model.key pageMsg pageModel
                |> Return.mapBoth (PageMsg << PublicationEditMsg) (updatePage model PublicationEdit)

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


mapPage : (a -> b) -> Browser.Document a -> Browser.Document b
mapPage f page =
    { title = page.title
    , body = List.map (Html.map f) page.body
    }



-- ROUTING


stepUrl : Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl url model =
    let
        parser =
            oneOf
                [ route top (stepHome model (HomePage.init Nothing))
                , route (top </> s "category" </> int)
                    (\categoryId ->
                        case model.page of
                            Home homeModel ->
                                stepHome model (HomePage.selectCategory (Just categoryId) homeModel)

                            _ ->
                                stepHome model (HomePage.selectCategory (Just categoryId) HomePage.initialModel)
                    )
                , route (top </> s "media-types")
                    (stepBrowseByMediaType model)
                , route (top </> s "categories")
                    (stepByCategory model (ByCategoryPage.init Nothing))
                , route (top </> s "categories" </> int)
                    (\categoryId -> stepByCategory model (ByCategoryPage.init (Just categoryId)))
                , route (top </> s "pub" </> int)
                    (\pubId -> stepPublication model (PublicationPage.init pubId))
                , route (top </> s "pub" </> s "edit" </> int)
                    (\pubId -> stepPublicationEdit model (PublicationEditPage.init pubId))
                , route (top </> s "read" </> int)
                    (\pubId -> stepRead model (ReadPage.init pubId Nothing))
                ]
    in
    case Parser.parse parser url of
        Just answer ->
            answer

        Nothing ->
            ( { model | page = Problem "404" }, Cmd.none )


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


stepPublicationEdit : Model -> ( PublicationEditPage.Model, Cmd PublicationEditPage.Msg ) -> ( Model, Cmd Msg )
stepPublicationEdit model ( pubModel, cmds ) =
    ( { model | page = PublicationEdit pubModel }
    , Cmd.map (PageMsg << PublicationEditMsg) cmds
    )


stepRead : Model -> ( ReadPage.Model, Cmd ReadPage.Msg ) -> ( Model, Cmd Msg )
stepRead model ( readModel, cmds ) =
    ( { model | page = Read readModel }
    , Cmd.map (PageMsg << ReadMsg) cmds
    )
