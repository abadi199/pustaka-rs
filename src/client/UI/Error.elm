module UI.Error exposing (view)

import Html.Styled exposing (..)


view : String -> Html msg
view error =
    div [] [ text error ]
