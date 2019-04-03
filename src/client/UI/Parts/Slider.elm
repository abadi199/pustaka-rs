module UI.Parts.Slider exposing (compact, large)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events as HE
import Json.Decode as JD
import UI.Background
import UI.Events as Events


slider : Int -> { onMouseMove : msg, onClick : Float -> msg, percentage : Float } -> Html msg
slider height { onMouseMove, onClick, percentage } =
    let
        percentageInHundred =
            percentage
                |> clamp 0 100

        heightInPixel =
            px (toFloat height)
    in
    div
        [ css
            [ UI.Background.transparentMediumBlack
            , width (pct 100)
            , Css.height heightInPixel
            , cursor pointer
            ]
        , HA.id "mySlider"
        , onClickGetX onClick
        , Events.onMouseMove onMouseMove
        ]
        [ div
            [ css
                [ UI.Background.transparentHeavyBlack
                , Css.height (pct 100)
                , flexBasis (pct 100)
                ]
            ]
            []
        ]


compact : { onMouseMove : msg, onClick : Float -> msg, percentage : Float } -> Html msg
compact { onMouseMove, onClick, percentage } =
    slider 5 { onMouseMove = onMouseMove, onClick = onClick, percentage = percentage }


large : { onMouseMove : msg, onClick : Float -> msg, percentage : Float } -> Html msg
large { onMouseMove, onClick, percentage } =
    slider 40 { onMouseMove = onMouseMove, onClick = onClick, percentage = percentage }


onClickGetX : (Float -> msg) -> Attribute msg
onClickGetX msg =
    HE.on "click"
        (JD.map2 (\x width -> msg ((x / width) * 100))
            (JD.field "clientX" JD.float)
            (JD.at [ "view", "innerWidth" ] JD.float)
        )
