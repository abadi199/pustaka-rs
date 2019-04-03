module UI.Background exposing
    ( lightRed
    , solidWhite
    , transparentHeavyBlack
    , transparentHeavyWhite
    , transparentLightBlack
    , transparentLightWhite
    , transparentMediumBlack
    , transparentMediumWhite
    )

import Css exposing (Style, backgroundColor, rgba)
import Html.Styled as H exposing (..)


solidWhite : Style
solidWhite =
    backgroundColor <| rgba 255 255 255 1


transparentLightWhite : Style
transparentLightWhite =
    backgroundColor <| rgba 255 255 255 0.025


transparentHeavyWhite : Style
transparentHeavyWhite =
    backgroundColor <| rgba 255 255 255 0.5


transparentMediumWhite : Style
transparentMediumWhite =
    backgroundColor <| rgba 255 255 255 0.125


transparentLightBlack : Style
transparentLightBlack =
    backgroundColor <| rgba 0 0 0 0.025


transparentHeavyBlack : Style
transparentHeavyBlack =
    backgroundColor <| rgba 0 0 0 0.25


transparentMediumBlack : Style
transparentMediumBlack =
    backgroundColor <| rgba 0 0 0 0.125


lightRed : Style
lightRed =
    backgroundColor <| rgba 255 186 186 1
