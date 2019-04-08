module UI.Reset exposing (reset)

import Css exposing (..)
import Css.Global as Global exposing (global)
import Html.Styled as H exposing (..)


reset : Html msg
reset =
    global
        [ Global.html
            [ boxSizing borderBox
            , fontSize (px 18)
            , fontFamilies [ "Source Sans Pro", "sans-serif" ]
            , fontWeight normal
            , overflowX hidden
            ]
        , Global.selector "*, *:before, *:after"
            [ boxSizing inherit
            , margin zero
            , padding zero
            , fontSize (Css.em 1)
            ]
        , Global.body
            [ margin zero
            , padding zero
            , overflowX hidden
            ]
        ]
