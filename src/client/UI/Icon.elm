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
    , small
    )

import Element exposing (..)
import Svg exposing (..)
import Svg.Attributes as S exposing (..)


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
    36


smallInt : Int
smallInt =
    24


height : Size -> Svg.Attribute msg
height size =
    case size of
        Small ->
            S.height <| String.fromInt smallInt

        Large ->
            S.height <| String.fromInt largeInt


width : Size -> Svg.Attribute msg
width size =
    case size of
        Small ->
            S.width <| String.fromInt smallInt

        Large ->
            S.width <| String.fromInt largeInt


none : Icon msg
none =
    Element.none


expandMore : Size -> Icon msg
expandMore size =
    html <|
        svg [ width size, height size, viewBox "0 0 24 24" ]
            [ Svg.path [ d "M16.59 8.59L12 13.17 7.41 8.59 6 10l6 6 6-6z" ]
                []
            , Svg.path [ d "M0 0h24v24H0z", S.fill "none" ]
                []
            ]


expandLess : Size -> Icon msg
expandLess size =
    html <|
        svg [ width size, height size, viewBox "0 0 24 24" ]
            [ Svg.path [ d "M12 8l-6 6 1.41 1.41L12 10.83l4.59 4.58L18 14z" ]
                []
            , Svg.path [ d "M0 0h24v24H0z", S.fill "none" ]
                []
            ]


edit : Size -> Icon msg
edit size =
    html <|
        svg [ width size, height size, viewBox "0 0 24 30" ]
            [ Svg.path [ d "M21,9.5a.5.5,0,0,0-.5.5V20a.5.5,0,0,1-.5.5H4a.5.5,0,0,1-.5-.5V4A.5.5,0,0,1,4,3.5H14a.5.5,0,0,0,0-1H4A1.5,1.5,0,0,0,2.5,4V20A1.5,1.5,0,0,0,4,21.5H20A1.5,1.5,0,0,0,21.5,20V10A.5.5,0,0,0,21,9.5Z" ]
                []
            , Svg.path [ d "M18.52,2.65a.5.5,0,0,0-.71,0l-7.9,7.9a.5.5,0,0,0-.12.2L8.38,15a.5.5,0,0,0,.47.66l.16,0,4.24-1.41a.5.5,0,0,0,.2-.12l7.9-7.9a.5.5,0,0,0,0-.71ZM12.83,13.29,9.65,14.35l1.06-3.18,7.46-7.46,2.12,2.12Z" ]
                []
            ]


read : Size -> Icon msg
read size =
    html <|
        svg [ width size, height size, viewBox "0 0 24 30" ]
            [ Svg.path [ d "M12,5.5c-5.18,0-9.24,6-9.42,6.22a.5.5,0,0,0,0,.56c.17.25,4.24,6.22,9.42,6.22s9.24-6,9.42-6.22a.5.5,0,0,0,0-.56C21.24,11.47,17.18,5.5,12,5.5Zm0,12c-4,0-7.53-4.35-8.39-5.5C4.47,10.84,7.95,6.5,12,6.5s7.53,4.35,8.39,5.5C19.53,13.16,16.05,17.5,12,17.5Z" ]
                []
            , Svg.path [ d "M12,9a3,3,0,1,0,3,3A3,3,0,0,0,12,9Zm0,5a2,2,0,1,1,2-2A2,2,0,0,1,12,14Z" ]
                []
            ]


delete : Size -> Icon msg
delete size =
    html <|
        svg [ viewBox "0 0 24 30", height size, width size ]
            [ Svg.path [ d "M13.93,18.5H14a.5.5,0,0,0,.49-.43l1-7a.5.5,0,0,0-1-.14l-1,7A.5.5,0,0,0,13.93,18.5Z" ]
                []
            , Svg.path [ d "M10,18.5h.07a.5.5,0,0,0,.42-.57l-1-7a.5.5,0,1,0-1,.14l1,7A.5.5,0,0,0,10,18.5Z" ]
                []
            , Svg.path [ d "M5,8.5h.54L6.5,21a.5.5,0,0,0,.5.46H17a.5.5,0,0,0,.5-.46l1-12.54H19a.5.5,0,0,0,.5-.5V6a.5.5,0,0,0-.4-.49L14.5,4.6V3a.5.5,0,0,0-.5-.5H10a.5.5,0,0,0-.5.5V4.59l-4.6.92A.5.5,0,0,0,4.5,6V8A.5.5,0,0,0,5,8.5Zm11.54,12H7.46l-.92-12H17.46Zm-6-17h3v1h-3Zm-5,2.91L10,5.5h4l4.55.91V7.5H5.5Z" ]
                []
            ]


next : Size -> Icon msg
next size =
    html <|
        svg [ viewBox "0 0 24 30", height size, width size ]
            [ Svg.path [ d "M10.15,15.35a.5.5,0,0,0,.71,0l3-3a.5.5,0,0,0,0-.71l-3-3a.5.5,0,0,0-.71.71L12.79,12l-2.65,2.65A.5.5,0,0,0,10.15,15.35Z" ]
                []
            ]


previous : Size -> Icon msg
previous size =
    html <|
        svg [ viewBox "0 0 24 30", height size, width size ]
            [ Svg.path [ d "M12.85,8.65a.5.5,0,0,0-.71,0l-3,3a.5.5,0,0,0,0,.71l3,3a.5.5,0,0,0,.71-.71L10.21,12l2.65-2.65A.5.5,0,0,0,12.85,8.65Z" ]
                []
            ]
