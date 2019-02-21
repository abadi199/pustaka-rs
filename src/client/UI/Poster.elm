module UI.Poster exposing (poster, thumbnail)

import Element as E exposing (..)
import Element.Background as Background
import Html as H
import Html.Attributes as HA


thumbnail : String -> Maybe String -> Element msg
thumbnail title cover =
    cover
        |> Maybe.map (coverThumbnail title)
        |> Maybe.withDefault (empty title)


poster : String -> Maybe String -> Element msg
poster title cover =
    cover
        |> Maybe.map (coverPoster title)
        |> Maybe.withDefault (empty title)


coverThumbnail : String -> String -> Element msg
coverThumbnail title url =
    image
        [ height (px 300)
        , htmlAttribute <| HA.title title
        ]
        { src = url, description = title }


coverPoster : String -> String -> Element msg
coverPoster title url =
    image
        [ height (px 500)
        , htmlAttribute <| HA.title title
        ]
        { src = url, description = title }


empty : String -> Element msg
empty title =
    el
        [ width fill
        , height fill
        , centerX
        , centerY
        , Background.color (rgba 0 0 0 0.35)
        , E.htmlAttribute <| HA.style "white-space" "normal"
        , E.htmlAttribute <| HA.title title
        ]
        (E.html <| H.text title)
