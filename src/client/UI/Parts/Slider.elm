module UI.Parts.Slider exposing (compact, large)

import Element as E exposing (..)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import UI.Background


slider : Int -> { onClick : Float -> msg, percentage : Float } -> Element msg
slider height { onClick, percentage } =
    let
        percentageInHundred =
            percentage
                * 100
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
        ]
        [ row
            [ UI.Background.transparentDarkBlack
            , E.height fill
            , htmlAttribute <| HA.style "flex-basis" (String.fromFloat percentageInHundred ++ "%")
            ]
            []
        ]


compact : { onClick : Float -> msg, percentage : Float } -> Element msg
compact { onClick, percentage } =
    slider 5 { onClick = onClick, percentage = percentage }


large : { onClick : Float -> msg, percentage : Float } -> Element msg
large { onClick, percentage } =
    slider 40 { onClick = onClick, percentage = percentage }


onClickGetX : (Float -> msg) -> Attribute msg
onClickGetX msg =
    htmlAttribute <|
        HE.on "click"
            (JD.map2 (\x width -> msg (x / width))
                (JD.field "clientX" JD.float)
                (JD.at [ "view", "innerWidth" ] JD.float)
            )
