module UI.Loading exposing (view)

import Element exposing (..)
import UI.Background


view : Element msg
view =
    el
        [ width fill
        , height fill
        , UI.Background.transparentHeavyWhite
        ]
        (el [ centerX, centerY ] <| text "Loading...")
