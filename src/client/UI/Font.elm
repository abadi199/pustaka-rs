module UI.Font exposing (darkRed)

import Css exposing (Style, color, rgba)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)


darkRed : Style
darkRed =
    color (rgba 216 0 12 1)
