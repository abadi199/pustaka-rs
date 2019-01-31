module UI.Card exposing (view)

import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA


view : List (Element msg) -> Element msg
view content =
    column
        [ width (px 200)
        , height (px 300)
        , Border.color (rgba 0 0 0 0.125)
        , Border.width 10
        , clip
        ]
        content
