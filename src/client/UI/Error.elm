module UI.Error exposing (http, string)

import Element exposing (..)
import Http
import UI.Background
import UI.Font
import UI.Spacing


string : String -> Element msg
string error =
    el
        [ centerX
        , centerY
        , UI.Background.lightRed
        , UI.Font.darkRed
        , UI.Spacing.padding -5
        ]
        (text error)


http : Http.Error -> Element msg
http error =
    string <| "Error"
