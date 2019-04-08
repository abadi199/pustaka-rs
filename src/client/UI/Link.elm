module UI.Link exposing (link)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA
import Html.Styled.Events as HE exposing (onClick)
import Json.Decode as JD


link : List (Attribute msg) -> { url : String, label : Html msg, msg : String -> msg } -> Html msg
link attrs { url, label, msg } =
    a (HA.href url :: onClick (msg url) :: attrs) [ label ]
