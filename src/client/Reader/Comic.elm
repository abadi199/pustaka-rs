module Reader.Comic exposing (reader)

import Css exposing (..)
import Element as E exposing (..)
import Entity.Publication as Publication
import Html as H
import Html.Attributes as HA
import Reader exposing (PageView(..))


reader : Publication.Data -> PageView -> Element msg
reader pub pageView =
    let
        imgStyle =
            batch [ Css.height (pct 100) ]
    in
    el []
        (case pageView of
            DoublePage pageNum ->
                E.row []
                    [ E.html <|
                        H.img
                            [ HA.src <|
                                "/api/publication/read/"
                                    ++ String.fromInt pub.id
                                    ++ "/page/"
                                    ++ String.fromInt pageNum
                            ]
                            []
                    , E.html <|
                        H.img
                            [ HA.src <|
                                "/api/publication/read/"
                                    ++ String.fromInt pub.id
                                    ++ "/page/"
                                    ++ String.fromInt (pageNum + 1)
                            ]
                            []
                    ]

            SinglePage pageNum ->
                E.html <|
                    H.img
                        [ HA.src <|
                            "/api/publication/read/"
                                ++ String.fromInt pub.id
                                ++ "/page/"
                                ++ String.fromInt pageNum
                        ]
                        []
        )
