module UI.Events exposing (onHtmlMouseMove, onMouseMove)

import Element as E
import Html as H
import Html.Events as HE
import Json.Decode as JD


onMouseMove : msg -> E.Attribute msg
onMouseMove msg =
    E.htmlAttribute <| onHtmlMouseMove msg


onHtmlMouseMove : msg -> H.Attribute msg
onHtmlMouseMove msg =
    HE.on "mousemove" (JD.succeed msg)
