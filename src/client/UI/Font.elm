module UI.Font exposing (darkRed)

import Element exposing (..)
import Element.Font


darkRed : Attribute msg
darkRed =
    Element.Font.color (rgba255 216 0 12 1)
