module UI.Link exposing (link)

import Css exposing (..)
import Element as E exposing (..)
import Element.Events exposing (onClick)
import Html as H
import Json.Decode as JD


link : List (Attribute msg) -> { url : String, label : Element msg, msg : String -> msg } -> E.Element msg
link attrs { url, label, msg } =
    E.link
        (attrs ++ [ onClick (msg url) ])
        { url = url
        , label = label
        }
