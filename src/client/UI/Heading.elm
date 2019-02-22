module UI.Heading exposing (heading)

import Element as E exposing (..)
import Element.Font as Font
import Element.Region as Region


scaled : Int -> Int
scaled =
    modular 24 1.25 >> round


heading : Int -> String -> Element msg
heading level content =
    el
        [ Region.heading level
        , Font.size (scaled (1 - level))
        , Font.bold
        ]
        (text content)
