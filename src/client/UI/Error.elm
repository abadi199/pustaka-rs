module UI.Error exposing (http, string)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Http
import UI.Background
import UI.Font
import UI.Spacing


string : String -> Html msg
string error =
    div
        [ css
            [ displayFlex
            , alignItems center
            , justifyContent center
            , UI.Background.lightRed
            , UI.Font.darkRed
            , UI.Spacing.padding UI.Spacing.Large
            ]
        ]
        [ text error ]


http : Http.Error -> Html msg
http error =
    string <| "Error"
