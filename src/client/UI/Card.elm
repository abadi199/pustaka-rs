module UI.Card exposing (bordered, simple)

import Html.Attributes as HA
import Html.Styled as H exposing (..)
import UI.Action as Action exposing (Action)
import UI.Poster as Poster


scaled : Int -> { width : Int, height : Int }
scaled scale =
    modular 300 1.25 scale
        |> round
        |> Poster.dimensionForHeight


card : Int -> List (Attribute msg) -> List (Html msg) -> Html msg
card scale attributes content =
    let
        { width, height } =
            scaled scale
    in
    column
        attributes
        content


bordered : List (Attribute msg) -> { actions : List (Action msg), content : List (Html msg) } -> Html msg
bordered attributes { actions, content } =
    card 1
        (Border.color (rgba 0 0 0 0.125)
            :: Border.width 10
            :: inFront (viewActions actions)
            :: attributes
        )
        content


viewActions : List (Action msg) -> Html msg
viewActions actions =
    row [ alignBottom, width fill, Background.color (rgba 1 1 1 0.75) ] [ row [ alignRight, alignBottom ] (actions |> List.map Action.toElement) ]


simple : List (Attribute msg) -> List (Html msg) -> Html msg
simple attributes content =
    card 3 attributes content
