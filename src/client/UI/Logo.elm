module UI.Logo exposing (full)

import Element as E exposing (..)
import UI.Spacing as Spacing


full : Element msg
full =
    el
        [ Spacing.padding 1 ]
        (text "Pustaka")
