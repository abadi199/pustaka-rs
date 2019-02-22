module UI.Poster exposing (poster, thumbnail)

import Element as E exposing (..)
import Element.Background as Background
import Html as H
import Html.Attributes as HA


dimensionForHeight : Int -> { width : Int, height : Int }
dimensionForHeight height =
    let
        width =
            toFloat height / 1.6 |> round
    in
    { width = width, height = height }


thumbnail : String -> Maybe String -> Element msg
thumbnail title cover =
    let
        { height, width } =
            dimensionForHeight 300
    in
    cover
        |> Maybe.map
            (\image ->
                posterImage
                    { width = width
                    , height = height
                    , image = image
                    , title = title
                    }
            )
        |> Maybe.withDefault (empty title)


poster : String -> Maybe String -> Element msg
poster title cover =
    let
        { width, height } =
            dimensionForHeight 500
    in
    cover
        |> Maybe.map
            (\image ->
                posterImage
                    { width = width
                    , height = height
                    , image = image
                    , title = title
                    }
            )
        |> Maybe.withDefault
            (el
                [ E.height <| px <| height
                , E.width <| px <| width
                ]
                (empty title)
            )


posterImage : { width : Int, height : Int, image : String, title : String } -> Element msg
posterImage { width, height, title, image } =
    E.image
        [ E.height (px height)
        , E.width (px width)
        , htmlAttribute <| HA.title title
        ]
        { src = image, description = title }


empty : String -> Element msg
empty title =
    el
        [ width fill
        , height fill
        , centerX
        , centerY
        , Background.color (rgba 0 0 0 0.35)
        , E.htmlAttribute <| HA.style "white-space" "normal"
        , E.htmlAttribute <| HA.style "overflow" "hidden"
        , E.htmlAttribute <| HA.title title
        ]
        (E.html <| H.text title)
