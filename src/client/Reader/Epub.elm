module Reader.Epub exposing (reader)

import Browser.Dom exposing (Viewport)
import Css exposing (..)
import Entity.Publication as Publication
import Html.Styled exposing (..)
import Html.Styled.Attributes as HA exposing (..)
import Json.Encode as JE
import Reader exposing (PageView(..))


reader : Viewport -> Publication.Data -> PageView -> Html msg
reader viewport pub pageView =
    node "epub-viewer"
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
