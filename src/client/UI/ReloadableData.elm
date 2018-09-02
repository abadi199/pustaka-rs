module UI.ReloadableData exposing (view)

import Html.Styled exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import UI.Error
import UI.Loading


view : (a -> Html msg) -> ReloadableWebData i a -> List (Html msg)
view successView reloadableData =
    case reloadableData of
        NotAsked _ ->
            []

        Loading _ ->
            [ UI.Loading.view ]

        Reloading publications ->
            [ UI.Loading.view, successView publications ]

        Success publications ->
            [ successView publications ]

        Failure error _ ->
            [ UI.Error.view "Error" ]

        FailureWithData error publications ->
            [ successView publications, UI.Error.view "Error" ]
