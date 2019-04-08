module UI.Image exposing (fullHeight, poster)

import Bytes exposing (Bytes)
import Css exposing (..)
import Entity.Image exposing (Image(..))
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)


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
                [ css
                    [ Css.height (px <| toFloat height)
                    , Css.width (px <| toFloat width)
                    , border3 (px 10) solid (rgba 0 0 0 0.125)
                    ]
                , HA.alt title
                , HA.title title
                , HA.src <| "data:*/*;base64," ++ base64
                ]
                []

        Empty ->
            text ""
