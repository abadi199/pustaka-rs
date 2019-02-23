module UI.Card exposing (bordered, simple)

import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import UI.Poster as Poster


scaled : Int -> { width : Int, height : Int }
scaled scale =
    modular 300 1.25 scale
        |> round
        |> Poster.dimensionForHeight


card : Int -> List (Attribute msg) -> List (Element msg) -> Element msg
card scale attributes content =
    let
        { width, height } =
            scaled scale
    in
    column
        attributes
        content


bordered : List (Attribute msg) -> List (Element msg) -> Element msg
bordered attributes =
    card 1
        (Border.color (rgba 0 0 0 0.125)
            :: Border.width 10
            :: attributes
        )


simple : List (Attribute msg) -> List (Element msg) -> Element msg
simple =
    card 3
