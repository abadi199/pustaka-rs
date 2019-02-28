module UI.Background exposing (dark, light, medium, white)

import Element exposing (..)
import Element.Background exposing (color)


white : Attribute msg
white =
    color (rgba 1 1 1 1)


light : Attribute msg
light =
    color (rgba 0 0 0 0.025)


dark : Attribute msg
dark =
    color (rgba 0 0 0 0.25)


medium : Attribute msg
medium =
    color (rgba 0 0 0 0.125)
