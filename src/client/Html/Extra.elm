module Html.Extra exposing (link)

import Html.Styled exposing (..)
import Html.Styled.Events exposing (..)
import Json.Decode as JD


link : msg -> List (Attribute msg) -> List (Html msg) -> Html msg
link msg attrs children =
    a (preventDefaultOn "click" (JD.succeed ( msg, True )) :: attrs) children
