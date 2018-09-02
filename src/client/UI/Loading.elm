module UI.Loading exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)


view : Html msg
view =
    div [ css [ color (rgba 255 255 255 1) ] ]
        [ text "Loading..."
        ]
