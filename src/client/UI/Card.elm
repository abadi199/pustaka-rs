module UI.Card exposing (bordered, simple)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import UI.Action as Action exposing (Action)
import UI.Poster as Poster


scaled : Int -> { width : Int, height : Int }
scaled scale =
    scale
        |> Poster.dimensionForHeight


card : Int -> List (Attribute msg) -> List (Html msg) -> Html msg
card scale attributes content =
    let
        { width, height } =
            scaled scale
    in
    div
        attributes
        content


bordered : List (Attribute msg) -> { actions : List (Action msg), content : List (Html msg) } -> Html msg
bordered attributes { actions, content } =
    card 1
        (css
            [ borderColor (rgba 0 0 0 0.125)
            , borderWidth (px 10)
            ]
            :: attributes
        )
        (viewActions actions :: content)


viewActions : List (Action msg) -> Html msg
viewActions actions =
    div [ css [ displayFlex, alignItems flexEnd, width (pct 100), backgroundColor (rgba 255 255 255 0.75) ] ]
        [ div [] (actions |> List.map Action.toHtml) ]


simple : List (Attribute msg) -> List (Html msg) -> Html msg
simple attributes content =
    card 3 attributes content
