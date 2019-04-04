module UI.List exposing (DD, DT, dd, dl, dt)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events as HE exposing (onClick)
import UI.Spacing as UI


dl : List ( DT msg, DD msg ) -> Html msg
dl list =
    H.dl resetStyles
        [ div [ css [ width (pct 100), UI.spacing -5 ] ] (list |> List.map viewDescription)
        ]


viewDescription : ( DT msg, DD msg ) -> Html msg
viewDescription ( DT term termOnClick, DD details detailsOnClick ) =
    div [ css [ width (pct 100) ] ]
        [ div [ css [ width (px 100) ] ] <|
            [ H.dt (onClick termOnClick :: resetStyles)
                [ text term ]
            ]
        , div []
            [ H.dd (onClick detailsOnClick :: resetStyles)
                [ text details ]
            ]
        ]


type DT msg
    = DT String msg


dt : { term : String, onClick : msg } -> DT msg
dt { term, onClick } =
    DT term onClick


type DD msg
    = DD String msg


dd : { details : String, onClick : msg } -> DD msg
dd { details, onClick } =
    DD details onClick


resetStyles : List (H.Attribute msg)
resetStyles =
    [ css [ margin zero, padding zero ]
    ]
