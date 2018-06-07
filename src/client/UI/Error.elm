module UI.Error exposing (view)

import Html exposing (..)


view : String -> Html msg
view error =
    div [] [ text error ]
