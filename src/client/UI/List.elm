module UI.List exposing (DD, DT, dd, dl, dt)

import Element exposing (..)
import Html exposing (Html, dd, dl, dt, span)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


dl : List ( DT msg, DD msg ) -> Element msg
dl list =
    html
        (Html.dl resetStyles
            [ column [] (list |> List.map viewDescription)
                |> layoutWith { options = [ noStaticStyleSheet ] } []
            ]
        )


viewDescription : ( DT msg, DD msg ) -> Element msg
viewDescription ( DT term termOnClick, DD details detailsOnClick ) =
    row []
        [ html
            (Html.dt (onClick termOnClick :: resetStyles)
                [ Html.text term ]
            )
        , html
            (Html.dd (onClick detailsOnClick :: resetStyles)
                [ Html.text details ]
            )
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


resetStyles : List (Html.Attribute msg)
resetStyles =
    [ style "margin" "0"
    , style "padding" "0"
    ]
