module UI.Css.Basics exposing (cardShadow, containerShadow)

import Css exposing (..)


cardShadow : Style
cardShadow =
    batch
        [ boxShadow4 zero (px 1) (px 3) (rgba 0 0 0 0.12)
        , boxShadow4 zero (px 1) (px 2) (rgba 0 0 0 0.24)
        ]


containerShadow : Style
containerShadow =
    batch
        [ boxShadow4 zero (px 2) (px 10) (rgba 0 0 0 0.12)
        , boxShadow4 zero (px 2) (px 8) (rgba 0 0 0 0.24)
        ]
