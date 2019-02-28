module UI.Poster exposing
    ( dimensionForHeight
    , poster
    , posterDimension
    , thumbnail
    , thumbnailDimension
    )

import Element as E exposing (..)
import Element.Background as Background
import Entity.Thumbnail as Thumbnail exposing (Thumbnail)
import Html as H
import Html.Attributes as HA


dimensionForHeight : Int -> { width : Int, height : Int }
dimensionForHeight height =
    let
        width =
            toFloat height / 1.6 |> round
    in
    { width = width, height = height }


posterDimension : { width : Int, height : Int }
posterDimension =
    dimensionForHeight 300


thumbnailDimension : { width : Int, height : Int }
thumbnailDimension =
    dimensionForHeight 200


thumbnail : { title : String, thumbnail : Thumbnail } -> Element msg
thumbnail args =
    let
        title =
            args.title

        cover =
            args.thumbnail

        { height, width } =
            thumbnailDimension
    in
    cover
        |> Thumbnail.toUrl
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


poster : { title : String, thumbnail : Thumbnail } -> Element msg
poster args =
    let
        title =
            args.title

        cover =
            args.thumbnail

        { width, height } =
            posterDimension
    in
    cover
        |> Thumbnail.toUrl
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
