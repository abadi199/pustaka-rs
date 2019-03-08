module UI.Image exposing (Image, fullHeight, image)

import Base64.Encode
import Bytes exposing (Bytes)
import Element as E exposing (Element, html)
import Html as H
import Html.Attributes as HA


type Image
    = Image String


image : Bytes -> Image
image bytes =
    bytes
        |> Base64.Encode.bytes
        |> Base64.Encode.encode
        |> Image


fullHeight : Image -> Element msg
fullHeight (Image base64) =
    html <| H.img [ HA.style "height" "100vh", HA.src <| "data:*/*;base64," ++ base64 ] []
