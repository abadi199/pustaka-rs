module Page.Main
    exposing
        ( Model
        , Msg
        , initialModel
        , update
        , view
        )

import Browser
import Entity.Category exposing (Category(..))
import Html exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import UI.Error
import UI.Loading
import UI.Menu


type alias Model =
    { categories : ReloadableWebData (List Category) }


initialModel : Model
initialModel =
    { categories = ReloadableData.NotAsked }


type Msg
    = GetCategoriesCompleted (ReloadableWebData (List Category))


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        GetCategoriesCompleted webData ->
            ( { model | categories = ReloadableData.refresh model.categories webData }
            , Cmd.none
            )


view : Model -> Browser.Page msg
view model =
    { title = "Pustaka - Main"
    , body = [ sideNav model.categories ]
    }


sideNav : ReloadableWebData (List Category) -> Html msg
sideNav data =
    let
        viewCategories categories =
            categories
                |> List.map (\(Category category) -> ( category.name, category.name ))
                |> UI.Menu.view
    in
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
