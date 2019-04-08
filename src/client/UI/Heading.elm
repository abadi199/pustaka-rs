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
            h1 [ css [ fontSize (px 24), overflow hidden ] ] [ text content ]

        Two ->
            h2 [ css [ fontSize (px 20), overflow hidden ] ] [ text content ]

        Three ->
            h3 [ css [ fontSize (px 18), overflow hidden ] ] [ text content ]

        Four ->
            h4 [ css [ fontSize (px 16), overflow hidden ] ] [ text content ]
