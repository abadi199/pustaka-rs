module UI.Image exposing (fullHeight, poster)

import Bytes exposing (Bytes)
import Entity.Image exposing (Image(..))
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA


fullHeight : Image -> Html msg
fullHeight img =
    case img of
        Image base64 ->
            H.img [ HA.style "height" "100vh", HA.src <| "data:*/*;base64," ++ base64 ] []

        Empty ->
            text ""


poster :
    { width : Int
    , height : Int
    , image : Image
    , title : String
    }
    -> Html msg
poster { width, height, title, image } =
    case image of
        Image base64 ->
            H.img
                [ HA.style "height" (String.fromInt height ++ "px")
                , HA.style "width" (String.fromInt width ++ "px")
                , HA.alt title
                , HA.title title
                , HA.src <| "data:*/*;base64," ++ base64
                ]
                []

        Empty ->
            text ""
