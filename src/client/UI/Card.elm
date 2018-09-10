module UI.Card exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UI.Css.Basics


view : List (Html msg) -> Html msg
view content =
    div
        [ css
            [ UI.Css.Basics.cardShadow
            , minHeight (Css.em 10)
            , margin (Css.em 0.5)
            , padding (Css.em 1)
            , displayFlex
            , flexDirection column
            , backgroundColor (rgba 255 255 255 0.5)
            ]
        ]
        content
