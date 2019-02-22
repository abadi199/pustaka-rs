module UI.Logo exposing (full)

import Element as E exposing (..)
import Element.Font as Font
import UI.Spacing as Spacing


full : Element msg
full =
    el
        [ Spacing.padding -2, Font.bold ]
        (text "Pustaka")
