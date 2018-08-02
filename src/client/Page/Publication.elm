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
import Browser.Navigation as Nav
import Entity.Category exposing (Category)
import Entity.Publication as Publication
import Html.Extra exposing (link)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set
import String
import Task
import Tree exposing (Tree)
import UI.Layout
import UI.Nav.Side
import UI.Parts.Search
import UI.ReloadableData


view : ReloadableWebData () (Tree Category) -> Model -> Browser.Document Msg
view categoryData model =
    UI.Layout.withSideNav
        { title = "Pustaka - Publication"
        , sideNav =
            categoryData
                |> UI.Nav.Side.view CategoryClicked (Set.fromList [])
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp))
        , content =
            [ div []
                (UI.ReloadableData.view
                    publicationView
                    model.publication
                )
            ]
        }


publicationView : Publication.MetaData -> Html Msg
publicationView publication =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        ]
        [ h2 [] [ text publication.title ]
        , posterView publication.id publication.thumbnail
        ]


posterView : Int -> Maybe String -> Html Msg
posterView publicationId maybePoster =
    case maybePoster of
        Just poster ->
            div []
                [ link (PublicationClicked publicationId)
                    [ href <| Route.readUrl publicationId ]
                    [ img [ src poster ] [] ]
                ]

        Nothing ->
            div [] []


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CategoryClicked id ->
            ( model, Nav.pushUrl key <| Route.categoryUrl id )

        GetPublicationCompleted data ->
            ( { model | publication = data }, Cmd.none )

        PublicationClicked pubId ->
            ( model, Nav.pushUrl key <| Route.readUrl pubId )


type alias Model =
    { publication : ReloadableWebData Int Publication.MetaData }


init : Int -> ( Model, Cmd Msg )
init publicationId =
    ( initialModel publicationId
    , Publication.get publicationId |> Task.perform GetPublicationCompleted
    )


initialModel : Int -> Model
initialModel publicationId =
    { publication = ReloadableData.Loading publicationId }


type Msg
    = CategoryClicked Int
    | GetPublicationCompleted (ReloadableWebData Int Publication.MetaData)
    | PublicationClicked Int
    | NoOp
