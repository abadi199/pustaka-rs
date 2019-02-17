module Reader.Comic exposing (reader)

import Element as E exposing (..)
import Entity.Publication as Publication
import Html as H
import Html.Attributes as HA
import Reader exposing (PageView(..))


reader : Publication.Data -> PageView -> Element msg
reader pub pageView =
    el []
        (case pageView of
            DoublePage pageNum ->
                E.row []
                    [ image pub.id pageNum
                    , image pub.id (pageNum + 1)
                    ]

            SinglePage pageNum ->
                image pub.id pageNum
        )


image : Int -> Int -> Element msg
image pubId pageNum =
    E.html <|
        H.img
            [ HA.src <| imageUrl pubId pageNum
            , HA.style "height" "100vh"
            ]
            []


imageUrl : Int -> Int -> String
imageUrl pubId pageNum =
    "/api/publication/read/"
        ++ String.fromInt pubId
        ++ "/page/"
        ++ String.fromInt pageNum
