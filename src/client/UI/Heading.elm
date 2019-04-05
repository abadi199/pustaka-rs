module UI.Heading exposing (Level(..), heading)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)


type Level
    = One
    | Two
    | Three
    | Four


heading : Level -> String -> Html msg
heading level content =
    case level of
        One ->
            h1 [ css [ fontSize (px 24) ] ] [ text content ]

        Two ->
            h2 [] [ text content ]

        Three ->
            h3 [] [ text content ]

        Four ->
            h4 [] [ text content ]
