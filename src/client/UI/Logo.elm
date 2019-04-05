module UI.Logo exposing (full)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (alt, css, src)


full : String -> Html msg
full logoUrl =
    img [ css [ height (px 50) ], src logoUrl, alt "" ] []
