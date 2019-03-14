module UI.Background exposing
    ( solidWhite
    , transparentHeavyBlack
    , transparentHeavyWhite
    , transparentLightBlack
    , transparentLightWhite
    , transparentMediumBlack
    , transparentMediumWhite
    )

import Element exposing (..)
import Element.Background exposing (color)


solidWhite : Attribute msg
solidWhite =
    color (rgba 1 1 1 1)


transparentLightWhite : Attribute msg
transparentLightWhite =
    color (rgba 1 1 1 0.025)


transparentHeavyWhite : Attribute msg
transparentHeavyWhite =
    color (rgba 1 1 1 0.5)


transparentMediumWhite : Attribute msg
transparentMediumWhite =
    color (rgba 1 1 1 0.125)


transparentLightBlack : Attribute msg
transparentLightBlack =
    color (rgba 0 0 0 0.025)


transparentHeavyBlack : Attribute msg
transparentHeavyBlack =
    color (rgba 0 0 0 0.25)


transparentMediumBlack : Attribute msg
transparentMediumBlack =
    color (rgba 0 0 0 0.125)
