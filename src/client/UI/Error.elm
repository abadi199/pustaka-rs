module UI.Error exposing (http, string)

import Element exposing (..)
import Http


string : String -> Element msg
string error =
    el [ centerX, centerY ] (text error)


http : Http.Error -> Element msg
http error =
    string <| Debug.toString error
