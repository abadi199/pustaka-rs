module Html.Extra exposing (link)

import Css exposing (..)
import Element as E exposing (..)
import Element.Events exposing (onClick)
import Html as H
import Json.Decode as JD


link : (String -> msg) -> List (Attribute msg) -> String -> Element msg -> E.Element msg
link msg attrs url label =
    E.link
        [ onClick (msg url) ]
        { url = url
        , label = label
        }
