module UI.Icon.Navigation exposing (expandMore)

import Element exposing (..)
import Svg exposing (..)
import Svg.Attributes as S exposing (..)


expandMore : Element msg
expandMore =
    html <|
        svg [ S.width "24", S.height "24", viewBox "0 0 24 24" ]
            [ Svg.path [ d "M16.59 8.59L12 13.17 7.41 8.59 6 10l6 6 6-6z" ]
                []
            , Svg.path [ d "M0 0h24v24H0z", S.fill "none" ]
                []
            ]


expandLess : Element msg
expandLess =
    html <|
        svg [ S.width "24", S.height "24", viewBox "0 0 24 24" ]
            [ Svg.path [ d "M12 8l-6 6 1.41 1.41L12 10.83l4.59 4.58L18 14z" ]
                []
            , Svg.path [ d "M0 0h24v24H0z", S.fill "none" ]
                []
            ]
