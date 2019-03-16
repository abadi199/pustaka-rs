module UI.Poster exposing
    ( dimensionForHeight
    , poster
    , posterDimension
    , reloadablePoster
    , thumbnail
    , thumbnailDimension
    )

import Element as E exposing (..)
import Element.Background as Background
import Entity.Image as Image exposing (Image)
import Entity.Thumbnail as Thumbnail exposing (Thumbnail)
import Html as H
import Html.Attributes as HA
import ReloadableData exposing (ReloadableWebData)
import UI.Image as Image
import UI.ReloadableData


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
            args.thumbnail |> Thumbnail.toImage

        { height, width } =
            thumbnailDimension
    in
    cover
        |> Image.toBase64
        |> Maybe.map
            (\image ->
                Image.poster
                    { width = width
                    , height = height
                    , image = Image.fromBase64 image
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


reloadablePoster : { title : String, image : ReloadableWebData i Image } -> Element msg
reloadablePoster { title, image } =
    let
        { width, height } =
            posterDimension
    in
    el
        [ E.height <| px <| height
        , E.width <| px <| width
        ]
        (UI.ReloadableData.view
            (\img ->
                img
                    |> Image.toBase64
                    |> Maybe.map
                        (\_ ->
                            Image.poster
                                { width = width
                                , height = height
                                , image = img
                                , title = title
                                }
                        )
                    |> Maybe.withDefault
                        (empty { width = width, height = height } title)
            )
            image
        )


poster : { title : String, image : Image } -> Element msg
poster { title, image } =
    let
        { width, height } =
            posterDimension
    in
    image
        |> Image.toBase64
        |> Maybe.map
            (\_ ->
                Image.poster
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
