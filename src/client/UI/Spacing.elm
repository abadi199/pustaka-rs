module UI.Spacing exposing (padding, paddingEach, spacing)

import Css exposing (..)
import Html.Styled as H exposing (Attribute)


spacing : Int -> Style
spacing scale =
    batch []


padding : Int -> Style
padding scale =
    paddingEach
        { top = scale
        , bottom = scale
        , right = scale
        , left = scale
        }


paddingEach : { top : Int, right : Int, bottom : Int, left : Int } -> Style
paddingEach { top, right, bottom, left } =
    padding4
        (px <| toFloat top)
        (px <| toFloat bottom)
        (px <| toFloat left)
        (px <| toFloat right)
