module UI.Heading exposing (heading)

import Html.Styled as H exposing (..)


heading : Int -> String -> Html msg
heading level content =
    div
        []
        [ text content ]
