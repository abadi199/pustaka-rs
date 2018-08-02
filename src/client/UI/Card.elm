module UI.Card exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)


view : List (Html msg) -> Html msg
view content =
    div
        [ css
            [ boxShadow4 zero (px 1) (px 3) (rgba 0 0 0 0.12)
            , boxShadow4 zero (px 1) (px 2) (rgba 0 0 0 0.24)
            , minHeight (Css.em 10)
            , margin (Css.em 0.5)
            , padding (Css.em 1)
            , displayFlex
            , flexDirection column
            , backgroundColor (rgba 255 255 255 0.5)
            ]
        ]
        content
