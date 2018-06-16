module Page.Main
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
import Entity.Category exposing (Category(..))
import Html exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import UI.Error
import UI.Loading
import UI.Menu


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.none
    )


initialModel : Model
initialModel =
    {}


type Msg
    = CategoryClicked Int


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        CategoryClicked id ->
            ( model, Navigation.pushUrl <| Route.categoryUrl id )


view : ReloadableWebData (List Category) -> Model -> Browser.Page Msg
view categories model =
    { title = "Pustaka - Main"
    , body = [ text "Welcome to Pustaka", sideNav categories ]
    }


sideNav : ReloadableWebData (List Category) -> Html Msg
sideNav data =
    div []
        (case data of
            NotAsked ->
                []

            Loading ->
                [ UI.Loading.view ]

            Reloading categories ->
                [ UI.Loading.view, viewCategories categories ]

            Success categories ->
                [ viewCategories categories ]

            Failure error ->
                [ UI.Error.view <| Debug.toString error ]

            FailureWithData error categories ->
                [ viewCategories categories, UI.Error.view <| Debug.toString error ]
        )


viewCategories : List Category -> Html Msg
viewCategories categories =
    categories
        |> List.map
            (\(Category category) ->
                { text = category.name
                , selected = category.selected
                , action = UI.Menu.click <| CategoryClicked category.id
                }
            )
        |> UI.Menu.view
