module UI.ReloadableData exposing (custom, view)

import Element as E exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import UI.Error
import UI.Loading


custom : (e -> Element msg) -> (a -> Element msg) -> ReloadableData e i a -> Element msg
custom errorElement successElement reloadableData =
    case reloadableData of
        NotAsked _ ->
            E.none

        Loading _ ->
            UI.Loading.view

        Reloading _ publications ->
            el [ inFront UI.Loading.view, width fill, height fill ] (successElement publications)

        Success _ publications ->
            successElement publications

        Failure error _ ->
            errorElement error

        FailureWithData error _ publications ->
            el [ inFront <| errorElement error, width fill, height fill ] (successElement publications)


view : (a -> Element msg) -> ReloadableWebData i a -> Element msg
view =
    custom UI.Error.http
