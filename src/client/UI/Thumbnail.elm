module UI.Thumbnail exposing (thumbnail)

import Element as E exposing (..)
import Html.Attributes as HA


thumbnail : String -> Maybe String -> Element msg
thumbnail title cover =
    cover
        |> Maybe.map (coverThumbnail title)
        |> Maybe.withDefault (emptyThumbnail title)


coverThumbnail : String -> String -> Element msg
coverThumbnail title url =
    image
        [ height (px 300)
        , htmlAttribute <| HA.title title
        ]
        { src = url, description = title }


emptyThumbnail : String -> Element msg
emptyThumbnail title =
    el [] (text title)
