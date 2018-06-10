module View exposing (view)

import Browser
import Entity.Category exposing (Category(..))
import Html exposing (..)
import Model exposing (Model)
import Msg exposing (Msg(..))
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import UI.Error
import UI.Loading
import UI.Menu


view : Model -> Browser.Page Msg
view model =
    { title = "Pustaka"
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
