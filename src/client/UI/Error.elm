module UI.Error exposing (view)

import Element exposing (..)


view : String -> Element msg
view error =
    el [] (text error)
