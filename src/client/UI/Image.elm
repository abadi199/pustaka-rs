module UI.Image exposing (fullHeight, poster)

import Bytes exposing (Bytes)
import Element as E exposing (Element, html)
import Entity.Image exposing (Image(..))
import Html as H
import Html.Attributes as HA


fullHeight : Image -> Element msg
fullHeight img =
    case img of
        Image base64 ->
            html <| H.img [ HA.style "height" "100vh", HA.src <| "data:*/*;base64," ++ base64 ] []

        Empty ->
            E.none


poster :
    { width : Int
    , height : Int
    , image : Image
    , title : String
    }
    -> Element msg
poster { width, height, title, image } =
    case image of
        Image base64 ->
            html <|
                H.img
                    [ HA.style "height" (String.fromInt height ++ "px")
                    , HA.style "width" (String.fromInt width ++ "px")
                    , HA.alt title
                    , HA.src <| "data:*/*;base64," ++ base64
                    ]
                    []

        Empty ->
            E.none
