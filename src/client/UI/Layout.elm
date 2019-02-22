module UI.Layout exposing (withSideNav)

import Browser
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import UI.Nav.Side exposing (SideNav)
import UI.Parts.Search exposing (Search)
import UI.Spacing as UI


withSideNav : { title : String, sideNav : SideNav msg, content : Element msg } -> Browser.Document msg
withSideNav { title, sideNav, content } =
    { title = title
    , body =
        [ layout [] <|
            E.row
                [ width fill
                , height fill
                ]
                ((sideNav |> UI.Nav.Side.toElement)
                    :: [ el
                            [ width fill
                            , height fill
                            , UI.padding 1
                            ]
                            content
                       ]
                )
        ]
    }
