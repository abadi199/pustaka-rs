module UI.Icon exposing
    ( Icon
    , Size
    , delete
    , edit
    , expandLess
    , expandMore
    , large
    , next
    , none
    , previous
    , read
    , save
    , small
    , spinner
    )

import Element exposing (..)
import Svg as S exposing (..)
import Svg.Attributes as SA exposing (..)


type alias Icon msg =
    Element msg


type Size
    = Large
    | Small


small : Size
small =
    Small


large : Size
large =
    Large


largeInt : Int
largeInt =
    48


smallInt : Int
smallInt =
    24


height : Size -> S.Attribute msg
height size =
    case size of
        Small ->
            SA.height <| String.fromInt smallInt

        Large ->
            SA.height <| String.fromInt largeInt


width : Size -> S.Attribute msg
width size =
    case size of
        Small ->
            SA.width <| String.fromInt smallInt

        Large ->
            SA.width <| String.fromInt largeInt


none : Icon msg
none =
    Element.none


expandMore : Size -> Icon msg
expandMore size =
    html <|
        svg [ width size, height size, viewBox "0 0 48 48" ]
            [ S.path [ d "M14.83 16.42L24 25.59l9.17-9.17L36 19.25l-12 12-12-12z" ]
                []
            , S.path [ d "M0-.75h48v48H0z", SA.fill "none" ]
                []
            ]


expandLess : Size -> Icon msg
expandLess size =
    html <|
        svg [ width size, height size, viewBox "0 0 48 48" ]
            [ S.path [ d "M14.83 30.83L24 21.66l9.17 9.17L36 28 24 16 12 28z" ]
                []
            , S.path [ d "M0 0h48v48H0z", SA.fill "none" ]
                []
            ]


edit : Size -> Icon msg
edit size =
    html <|
        svg [ width size, height size, viewBox "0 0 48 48" ]
            [ S.path [ d "M6 34.5V42h7.5l22.13-22.13-7.5-7.5L6 34.5zm35.41-20.41c.78-.78.78-2.05 0-2.83l-4.67-4.67c-.78-.78-2.05-.78-2.83 0l-3.66 3.66 7.5 7.5 3.66-3.66z" ]
                []
            , S.path [ d "M0 0h48v48H0z", SA.fill "none" ]
                []
            ]


read : Size -> Icon msg
read size =
    html <|
        svg [ width size, height size, viewBox "0 0 48 48" ]
            [ S.path [ d "M0 0h48v48H0z", SA.fill "none" ]
                []
            , S.path [ d "M24 9C14 9 5.46 15.22 2 24c3.46 8.78 12 15 22 15s18.54-6.22 22-15C42.54 15.22 34.01 9 24 9zm0 25c-5.52 0-10-4.48-10-10s4.48-10 10-10 10 4.48 10 10-4.48 10-10 10zm0-16c-3.31 0-6 2.69-6 6s2.69 6 6 6 6-2.69 6-6-2.69-6-6-6z" ]
                []
            ]


delete : Size -> Icon msg
delete size =
    html <|
        svg [ width size, height size, viewBox "0 0 48 48" ]
            [ S.path [ d "M12 38c0 2.21 1.79 4 4 4h16c2.21 0 4-1.79 4-4V14H12v24zM38 8h-7l-2-2H19l-2 2h-7v4h28V8z" ]
                []
            , S.path [ d "M0 0h48v48H0z", SA.fill "none" ]
                []
            ]


next : Size -> Icon msg
next size =
    html <|
        svg [ width size, height size, viewBox "0 0 48 48" ]
            [ S.path [ d "M20 12l-2.83 2.83L26.34 24l-9.17 9.17L20 36l12-12z" ]
                []
            , S.path [ d "M0 0h48v48H0z", SA.fill "none" ]
                []
            ]


previous : Size -> Icon msg
previous size =
    html <|
        svg [ width size, height size, viewBox "0 0 48 48" ]
            [ S.path [ d "M31.83 14.83L28 12 16 24l12 12 2.83-2.83L21.66 24z" ]
                []
            , S.path [ d "M0 0h48v48H0z", SA.fill "none" ]
                []
            ]


save : Size -> Icon msg
save size =
    html <|
        svg [ width size, height size, viewBox "0 0 48 48" ]
            [ S.path [ d "M0 0h48v48H0z", SA.fill "none" ]
                []
            , S.path [ d "M34 6H10c-2.21 0-4 1.79-4 4v28c0 2.21 1.79 4 4 4h28c2.21 0 4-1.79 4-4V14l-8-8zM24 38c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6zm6-20H10v-8h20v8z" ]
                []
            ]


spinner : Size -> Icon msg
spinner size =
    html <|
        svg [ viewBox "1733.677 591.447 332.27042 578.33928", width size, height size ]
            [ defs []
                [ S.node "style"
                    [ type_ "text/css" ]
                    [ S.text """
.bookmark {
  stroke: #df345c;
  stroke-width: 50;
  stroke-dasharray: 2000;
  stroke-dashoffset: 2000;
  animation: dash 1.5s infinite;
  fill: none;
}

@keyframes dash {
  to {
    stroke-dashoffset: 0;
  }
}
"""
                    ]
                ]
            , S.path [ class "bookmark", d "m 2036.9354,616.447 h -274.209 c -30.3,0 -54.567,24.542 -54.567,54.842 l -0.274,438.733 191.945,-189.117 191.946,189.117 V 671.289 c 0,-30.3 -24.541,-54.842 -54.841,-54.842 z" ]
                []
            ]
