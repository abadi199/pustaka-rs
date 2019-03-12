module UI.Parts.Slider exposing (compact, large)

import Element as E exposing (..)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import UI.Background
import UI.Events as Events


slider : Int -> { onMouseMove : msg, onClick : Float -> msg, percentage : Float } -> Element msg
slider height { onMouseMove, onClick, percentage } =
    let
        percentageInHundred =
            percentage
                |> clamp 0 100

        heightInPixel =
            px height
    in
    row
        [ alignBottom
        , centerX
        , UI.Background.transparentMediumBlack
        , width fill
        , E.height heightInPixel
        , pointer
        , htmlAttribute <| HA.id "mySlider"
        , onClickGetX onClick
        , Events.onMouseMove onMouseMove
        ]
        [ row
            [ UI.Background.transparentHeavyBlack
            , E.height fill
            , htmlAttribute <| HA.style "flex-basis" (String.fromFloat percentageInHundred ++ "%")
            ]
            []
        ]


compact : { onMouseMove : msg, onClick : Float -> msg, percentage : Float } -> Element msg
compact { onMouseMove, onClick, percentage } =
    slider 5 { onMouseMove = onMouseMove, onClick = onClick, percentage = percentage }


large : { onMouseMove : msg, onClick : Float -> msg, percentage : Float } -> Element msg
large { onMouseMove, onClick, percentage } =
    slider 40 { onMouseMove = onMouseMove, onClick = onClick, percentage = percentage }


onClickGetX : (Float -> msg) -> Attribute msg
onClickGetX msg =
    htmlAttribute <|
        HE.on "click"
            (JD.map2 (\x width -> msg ((x / width) * 100))
                (JD.field "clientX" JD.float)
                (JD.at [ "view", "innerWidth" ] JD.float)
            )
