module Keyboard exposing (onEscape, onLeft, onRight)

import Browser.Events
import Json.Decode as JD exposing (Decoder)


onEscape : msg -> Sub msg
onEscape msg =
    Browser.Events.onKeyUp
        (JD.oneOf
            [ key "Escape" msg
            , key "Esc" msg
            ]
        )


onLeft : msg -> Sub msg
onLeft msg =
    Browser.Events.onKeyUp (key "ArrowLeft" msg)


onRight : msg -> Sub msg
onRight msg =
    Browser.Events.onKeyUp (key "ArrowRight" msg)


key : String -> msg -> Decoder msg
key keyString msg =
    JD.field "key" JD.string
        |> JD.andThen
            (\str ->
                if String.toUpper str == String.toUpper keyString then
                    JD.succeed msg

                else
                    JD.fail <| "Not " ++ keyString
            )
