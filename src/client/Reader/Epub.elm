module Reader.Epub exposing (reader)

import Browser.Dom exposing (Viewport)
import Css exposing (..)
import Element as E exposing (..)
import Entity.Publication as Publication
import Html as H
import Html.Attributes as HA
import Json.Encode as JE
import Reader exposing (PageView(..))


reader : Viewport -> Publication.Data -> PageView -> Element msg
reader viewport pub pageView =
    E.html <|
        H.node "epub-viewer"
            [ pub.id
                |> String.fromInt
                |> (\id ->
                        "/api/publication/download/"
                            ++ id
                            ++ "/epub"
                   )
                |> HA.attribute "epub"
            , HA.attribute "width" (viewport.viewport.width - 200 |> String.fromFloat)
            , HA.attribute "height" (viewport.viewport.height |> String.fromFloat)
            ]
            []
