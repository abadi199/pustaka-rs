module UI.Poster exposing
    ( dimensionForHeight
    , poster
    , posterDimension
    , reloadablePoster
    , reloadableThumbnail
    , thumbnail
    , thumbnailDimension
    )

import Css exposing (..)
import Entity.Image as Image exposing (Image)
import Entity.Thumbnail as Thumbnail exposing (Thumbnail)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import ReloadableData exposing (ReloadableWebData)
import UI.Image as Image
import UI.ReloadableData


dimensionForHeight : Int -> { width : Int, height : Int }
dimensionForHeight height =
    let
        width =
            toFloat height / 1.6 |> Basics.round
    in
    { width = width, height = height }


posterDimension : { width : Int, height : Int }
posterDimension =
    dimensionForHeight 300


thumbnailDimension : { width : Int, height : Int }
thumbnailDimension =
    dimensionForHeight 200


reloadableThumbnail : { title : String, image : ReloadableWebData i Image } -> Html msg
reloadableThumbnail { title, image } =
    let
        { height, width } =
            thumbnailDimension
    in
    div
        [ css
            [ Css.height (px (toFloat height))
            , Css.width (px (toFloat width))
            ]
        ]
        [ UI.ReloadableData.view
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
                        (empty
                            { width = width
                            , height = height
                            }
                            title
                        )
            )
            image
        ]


thumbnail : { title : String, image : Image } -> Html msg
thumbnail { title, image } =
    let
        { height, width } =
            thumbnailDimension
    in
    image
        |> Image.toBase64
        |> Maybe.map
            (\img ->
                Image.poster
                    { width = width
                    , height = height
                    , image = Image.fromBase64 img
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


reloadablePoster : { title : String, image : ReloadableWebData i Image } -> Html msg
reloadablePoster { title, image } =
    let
        { width, height } =
            posterDimension
    in
    div
        [ css
            [ Css.height (px <| toFloat height)
            , Css.width (px <| toFloat width)
            ]
        ]
        [ UI.ReloadableData.view
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
        ]


poster : { title : String, image : Image } -> Html msg
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
            (div
                [ css
                    [ Css.height (px <| toFloat height)
                    , Css.width (px <| toFloat width)
                    ]
                ]
                [ empty { width = width, height = height } title ]
            )


empty : { width : Int, height : Int } -> String -> Html msg
empty { width, height } title =
    div
        [ css
            [ Css.width (px <| toFloat width)
            , Css.height (px <| toFloat height)
            , displayFlex
            , alignItems flexEnd
            , backgroundColor (rgba 0 0 0 0.35)
            , whiteSpace normal
            , overflow hidden
            , justifyContent center
            , textAlign center
            ]
        , HA.title title
        ]
        [ H.text title ]
