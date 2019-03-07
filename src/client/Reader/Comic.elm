module Reader.Comic exposing (reader, view)

import Browser.Dom exposing (Viewport)
import Element as E exposing (..)
import Entity.Publication as Publication
import Html as H
import Html.Attributes as HA
import Reader exposing (PageView(..))
import UI.Events
import UI.Parts.Header as Header


view :
    { publication : Publication.Data
    , viewport : Viewport
    , pageView : PageView
    , slider : Element msg
    , header : Element msg
    , onMouseMove : msg
    , onLinkClicked : String -> msg
    , left : Element msg
    , right : Element msg
    }
    -> Element msg
view { publication, viewport, pageView, header, slider, left, right, onMouseMove, onLinkClicked } =
    row
        [ inFront <| header
        , inFront <| slider
        , width fill
        ]
        [ left
        , E.el
            [ centerX
            , UI.Events.onMouseMove onMouseMove
            ]
            (reader publication pageView)
        , right
        ]


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
