module UI.Layout exposing (withSideNav)

import Browser
import Element as E exposing (..)
import UI.Nav.Side exposing (SideNav)
import UI.Parts.Search exposing (Search)


withSideNav : { title : String, sideNav : SideNav msg, content : List (Element msg) } -> Browser.Document msg
withSideNav { title, sideNav, content } =
    { title = title
    , body =
        [ layout [] <|
            E.row
                []
                ((sideNav |> UI.Nav.Side.toElement)
                    :: content
                )
        ]
    }
