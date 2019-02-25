module UI.Icon exposing
    ( Icon
    , edit
    , expandLess
    , expandMore
    , read
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
        svg [ S.width "24", S.height "24", viewBox "0 0 24 30" ]
            [ Svg.path [ d "M21,9.5a.5.5,0,0,0-.5.5V20a.5.5,0,0,1-.5.5H4a.5.5,0,0,1-.5-.5V4A.5.5,0,0,1,4,3.5H14a.5.5,0,0,0,0-1H4A1.5,1.5,0,0,0,2.5,4V20A1.5,1.5,0,0,0,4,21.5H20A1.5,1.5,0,0,0,21.5,20V10A.5.5,0,0,0,21,9.5Z" ]
                []
            , Svg.path [ d "M18.52,2.65a.5.5,0,0,0-.71,0l-7.9,7.9a.5.5,0,0,0-.12.2L8.38,15a.5.5,0,0,0,.47.66l.16,0,4.24-1.41a.5.5,0,0,0,.2-.12l7.9-7.9a.5.5,0,0,0,0-.71ZM12.83,13.29,9.65,14.35l1.06-3.18,7.46-7.46,2.12,2.12Z" ]
                []
            ]


read : Icon msg
read =
    html <|
        svg [ S.width "24", S.height "24", viewBox "0 0 24 30" ]
            [ Svg.path [ d "M12,5.5c-5.18,0-9.24,6-9.42,6.22a.5.5,0,0,0,0,.56c.17.25,4.24,6.22,9.42,6.22s9.24-6,9.42-6.22a.5.5,0,0,0,0-.56C21.24,11.47,17.18,5.5,12,5.5Zm0,12c-4,0-7.53-4.35-8.39-5.5C4.47,10.84,7.95,6.5,12,6.5s7.53,4.35,8.39,5.5C19.53,13.16,16.05,17.5,12,17.5Z" ]
                []
            , Svg.path [ d "M12,9a3,3,0,1,0,3,3A3,3,0,0,0,12,9Zm0,5a2,2,0,1,1,2-2A2,2,0,0,1,12,14Z" ]
                []
            ]
