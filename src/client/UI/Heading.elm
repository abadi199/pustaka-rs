module UI.Heading exposing (Level(..), heading)

import Html.Styled as H exposing (..)


type Level
    = One
    | Two
    | Three
    | Four


heading : Level -> String -> Html msg
heading level content =
    case level of
        One ->
            h1 [] [ text content ]

        Two ->
            h2 [] [ text content ]

        Three ->
            h3 [] [ text content ]

        Four ->
            h4 [] [ text content ]
