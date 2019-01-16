module Reader.Epub exposing (reader)

import Css exposing (..)
import Entity.Publication as Publication
import Html.Styled exposing (..)
import Html.Styled.Attributes as HA exposing (..)
import Json.Encode as JE
import Reader exposing (PageView(..))


reader : Publication.Data -> PageView -> Html msg
reader pub pageView =
    node "epub-viewer"
        [ pub.id
            |> String.fromInt
            |> (\id ->
                    "/api/publication/download/"
                        ++ id
                        ++ "/epub"
               )
            |> HA.attribute "epub"
        ]
        []
