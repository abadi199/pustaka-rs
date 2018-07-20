module Main exposing (main)

-- import Page.Publication as PublicationPage
-- import Page.Read as ReadPage

import Browser
import Browser.Navigation as Nav
import Entity.Category exposing (Category)
import Html exposing (..)
import Page.Home as HomePage
import Page.Problem as ProblemPage
import ReloadableData exposing (ReloadableWebData)
import Route exposing (Route)
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
    , categories : ReloadableWebData () (Tree Category)
    }


type Page
    = Home HomePage.Model
      -- | Publication PublicationPage.Model
      -- | Read ReadPage.Model
    | Problem String


type Msg
    = NoOp
    | GetCategoriesCompleted (ReloadableWebData () (Tree Category))
    | UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | HomeMsg HomePage.Msg



-- | PublicationMsg PublicationPage.Msg
-- | ReadMsg ReadPage.Msg


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
                , categories = ReloadableData.Loading ()
                }
    in
    ( model
    , Cmd.batch [ cmd, Entity.Category.list GetCategoriesCompleted ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetCategoriesCompleted data ->
            ( { model | categories = data }, Cmd.none )

        UrlChanged url ->
            stepUrl url model

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        HomeMsg homeMsg ->
            ( model, Cmd.none )



-- case model.page of
--     Home homeModel ->
--         let
--             ( newHomeModel, cmds ) =
--                 HomePage.update homeMsg homeModel
--         in
--         ( { model | page = Home newHomeModel }
--         , cmds |> Cmd.map HomeMsg
--         )
--     _ ->
--         ( model, Cmd.none )
-- PublicationMsg pubMsg ->
--     case model.page of
--         Publication pubModel ->
--             let
--                 ( newPubModel, cmds ) =
--                     PublicationPage.update pubMsg pubModel
--             in
--             ( { model | page = Publication newPubModel }
--             , cmds |> Cmd.map PublicationMsg
--             )
--         _ ->
--             ( model, Cmd.none )
-- ReadMsg readMsg ->
--     case model.page of
--         Read readModel ->
--             let
--                 ( newReadModel, cmds ) =
--                     ReadPage.update readMsg readModel
--             in
--             ( { model | page = Read newReadModel }, cmds |> Cmd.map ReadMsg )
--         _ ->
--             ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    case model.page of
        Home homeModel ->
            HomePage.view model.categories homeModel
                |> mapPage HomeMsg

        -- Publication publicationModel ->
        --     PublicationPage.view model.categories publicationModel
        --         |> mapPage PublicationMsg
        -- Read readModel ->
        --     ReadPage.view readModel
        --         |> mapPage ReadMsg
        Problem text ->
            ProblemPage.view text


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
                        let
                            _ =
                                Debug.log "route.category" categoryId
                        in
                        case model.page of
                            Home homeModel ->
                                stepHome model (HomePage.selectCategories (Set.fromList [ categoryId ]) homeModel)

                            _ ->
                                stepHome model (HomePage.selectCategories (Set.fromList [ categoryId ]) HomePage.initialModel)
                    )
                ]
    in
    case Parser.parse parser url of
        Just answer ->
            answer

        Nothing ->
            ( model, Cmd.none )


route : Parser a b -> a -> Parser (b -> c) c
route parser handler =
    Parser.map handler parser


stepHome : Model -> ( HomePage.Model, Cmd HomePage.Msg ) -> ( Model, Cmd Msg )
stepHome model ( homeModel, cmds ) =
    ( { model | page = Home homeModel }
    , Cmd.map HomeMsg (Cmd.batch [ cmds ])
    )
