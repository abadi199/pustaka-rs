module UI.Card exposing (bordered, simple)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import UI.Action as Action exposing (Action)
import UI.Poster as Poster
import UI.Spacing as Spacing


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
    node "poster"
        attributes
        content


bordered :
    List (Attribute msg)
    ->
        { actions : List (Action msg)
        , content : List (Html msg)
        }
    -> Html msg
bordered attributes { actions, content } =
    card 1
        (css
            [ borderColor (rgba 255 0 0 0.125)
            , borderWidth (px 10)
            , position relative
            , displayFlex
            , justifyContent center
            , lastOfType [ Spacing.marginRight Spacing.None ]
            , Spacing.marginEach
                { top = Spacing.Medium
                , right = Spacing.Large
                , bottom = Spacing.Medium
                , left = Spacing.None
                }
            ]
            :: HA.class "bla"
            :: attributes
        )
        (viewActions actions :: content)


viewActions : List (Action msg) -> Html msg
viewActions actions =
    div
        [ css
            [ position absolute
            , displayFlex
            , justifyContent flexEnd
            , bottom (px 0)
            , alignItems flexEnd
            , width (pct 100)
            , backgroundColor (rgba 255 255 255 0.75)
            , Spacing.paddingLeft Spacing.Small
            , Spacing.paddingRight Spacing.Small
            ]
        ]
        [ div [] (actions |> List.map Action.toHtml) ]


simple : List (Attribute msg) -> List (Html msg) -> Html msg
simple attributes content =
    card 3 attributes content
