module UI.Loading exposing (view)

import Element exposing (..)
import UI.Background
import UI.Icon as Icon


view : Element msg
view =
    el
        [ width fill
        , height fill
        , UI.Background.transparentHeavyWhite
        ]
        (el [ centerX, centerY ] <| Icon.spinner Icon.large)
