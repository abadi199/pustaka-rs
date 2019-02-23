module UI.Icon exposing
    ( Icon
    , edit
    , expandLess
    , expandMore
    )

import Element exposing (..)
import Svg exposing (..)
import Svg.Attributes as S exposing (..)


type alias Icon msg =
    Element msg


expandMore : Icon msg
expandMore =
    html <|
        svg [ S.width "24", S.height "24", viewBox "0 0 24 24" ]
            [ Svg.path [ d "M16.59 8.59L12 13.17 7.41 8.59 6 10l6 6 6-6z" ]
                []
            , Svg.path [ d "M0 0h24v24H0z", S.fill "none" ]
                []
            ]


expandLess : Icon msg
expandLess =
    html <|
        svg [ S.width "24", S.height "24", viewBox "0 0 24 24" ]
            [ Svg.path [ d "M12 8l-6 6 1.41 1.41L12 10.83l4.59 4.58L18 14z" ]
                []
            , Svg.path [ d "M0 0h24v24H0z", S.fill "none" ]
                []
            ]


edit : Icon msg
edit =
    html <|
        svg [ S.width "24", S.height "24", viewBox "0 0 35 43.7" ]
            [ g []
                [ Svg.path [ d "M1.9,27.9v3.2c0,1.1,0.9,2,2,2h3.2c0.5,0,1-0.2,1.4-0.6l18.9-18.9l-6-6L2.5,26.5C2.1,26.9,1.9,27.4,1.9,27.9z" ]
                    []
                , Svg.path [ d "M32.5,5.7l-3.2-3.2c-0.8-0.8-2-0.8-2.8,0l-3.1,3.1l6,6l3.1-3.1C33.3,7.7,33.3,6.5,32.5,5.7z" ]
                    []
                ]
            ]
