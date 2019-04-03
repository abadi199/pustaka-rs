module UI.ReloadableData exposing (custom, view)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import UI.Error
import UI.Loading


custom : (e -> Html msg) -> (a -> Html msg) -> ReloadableData e i a -> Html msg
custom errorElement successElement reloadableData =
    case reloadableData of
        NotAsked _ ->
            text ""

        Loading _ ->
            UI.Loading.view

        Reloading _ publications ->
            div
                [ css
                    [ height (pct 100)
                    , width (pct 10)
                    , position relative
                    ]
                ]
                [ successElement publications
                , UI.Loading.view
                ]

        Success _ publications ->
            successElement publications

        Failure error _ ->
            errorElement error

        FailureWithData error _ publications ->
            div
                [ css
                    [ width (pct 100)
                    , height (pct 100)
                    ]
                ]
                [ successElement publications, errorElement error ]


view : (a -> Html msg) -> ReloadableWebData i a -> Html msg
view =
    custom UI.Error.http
