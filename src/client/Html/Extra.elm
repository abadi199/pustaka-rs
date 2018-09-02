module Html.Extra exposing (link)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (href)
import Html.Styled.Events exposing (..)
import Json.Decode as JD


link : (String -> msg) -> String -> List (Attribute msg) -> List (Html msg) -> Html msg
link msg url attrs children =
    a
        (href url
            :: preventDefaultOn "click" (JD.succeed ( msg url, True ))
            :: attrs
        )
        children
