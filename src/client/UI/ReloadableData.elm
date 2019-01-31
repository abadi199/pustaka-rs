module UI.ReloadableData exposing (view)

import Element as E exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import UI.Error
import UI.Loading


view : (a -> Element msg) -> ReloadableWebData i a -> Element msg
view successElement reloadableData =
    case reloadableData of
        NotAsked _ ->
            E.none

        Loading _ ->
            UI.Loading.view

        Reloading publications ->
            el [ inFront UI.Loading.view ] (successElement publications)

        Success publications ->
            successElement publications

        Failure error _ ->
            UI.Error.view <| Debug.toString error

        FailureWithData error publications ->
            el [ inFront <| UI.Error.view <| Debug.toString error ] (successElement publications)
