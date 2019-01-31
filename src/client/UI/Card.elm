module UI.Card exposing (view)

import Element as E exposing (..)


view : List (Element msg) -> Element msg
view content =
    row
        []
        content
