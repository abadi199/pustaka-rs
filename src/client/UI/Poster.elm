module UI.Poster exposing (dimensionForHeight, poster, thumbnail)

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
            dimensionForHeight 200
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
            (empty
                { width = width
                , height = height
                }
                title
            )


poster : String -> Maybe String -> Element msg
poster title cover =
    let
        { width, height } =
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
        |> Maybe.withDefault
            (el
                [ E.height <| px <| height
                , E.width <| px <| width
                ]
                (empty { width = width, height = height } title)
            )


posterImage :
    { width : Int
    , height : Int
    , image : String
    , title : String
    }
    -> Element msg
posterImage { width, height, title, image } =
    E.image
        [ E.height (px height)
        , E.width (px width)
        , htmlAttribute <| HA.title title
        ]
        { src = image, description = title }


empty : { width : Int, height : Int } -> String -> Element msg
empty { width, height } title =
    el
        [ E.width (px width)
        , E.height (px height)
        , alignBottom
        , Background.color (rgba 0 0 0 0.35)
        , E.htmlAttribute <| HA.title title
        , E.htmlAttribute <| HA.style "white-space" "normal"
        , E.htmlAttribute <| HA.style "overflow" "hidden"
        , E.htmlAttribute <| HA.style "justify-content" "center"
        , E.htmlAttribute <| HA.style "align-items" "center"
        , E.htmlAttribute <| HA.style "text-align" "center"
        ]
        (E.html <| H.text title)
