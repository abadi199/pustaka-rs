module UI.Events exposing (onMouseMove)

import Html.Styled as H
import Html.Styled.Events as HE
import Json.Decode as JD


onMouseMove : msg -> H.Attribute msg
onMouseMove msg =
    HE.on "mousemove" (JD.succeed msg)
