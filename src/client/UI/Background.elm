module UI.Background exposing
    ( solidWhite
    , transparentDarkBlack
    , transparentLightBlack
    , transparentMediumBlack
    )

import Element exposing (..)
import Element.Background exposing (color)


solidWhite : Attribute msg
solidWhite =
    color (rgba 1 1 1 1)


transparentLightBlack : Attribute msg
transparentLightBlack =
    color (rgba 0 0 0 0.025)


transparentDarkBlack : Attribute msg
transparentDarkBlack =
    color (rgba 0 0 0 0.25)


transparentMediumBlack : Attribute msg
transparentMediumBlack =
    color (rgba 0 0 0 0.125)
