module UI.Card exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : List (Html msg) -> Html msg
view content =
    div
        [ style "box-shadow" "0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24)"
        , style "min-height" "10em"
        , style "margin" "0.5em"
        , style "padding" "1em"
        ]
        content
