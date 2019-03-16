module Entity.Thumbnail exposing
    ( Thumbnail
    , fromBase64
    , hasThumbnail
    , new
    , none
    , thumbnailDecoder
    , toImage
    )

import Entity.Image as Image exposing (Image)
import File exposing (File)
import Json.Decode as JD


type Thumbnail
    = NoThumbnail
    | New File
    | Image String


hasThumbnail : Thumbnail -> Bool
hasThumbnail thumbnail =
    case thumbnail of
        NoThumbnail ->
            False

        New _ ->
            False

        Image _ ->
            True


toImage : Thumbnail -> Image
toImage thumbnail =
    case thumbnail of
        NoThumbnail ->
            Image.none

        New file ->
            Image.none

        Image base64 ->
            Image.fromBase64 base64


none : Thumbnail
none =
    NoThumbnail


new : File -> Thumbnail
new =
    New


fromBase64 : String -> Thumbnail
fromBase64 =
    Image


thumbnailDecoder : JD.Decoder Thumbnail
thumbnailDecoder =
    JD.oneOf
        [ JD.string
            |> JD.map
                (\urlValue ->
                    case urlValue of
                        "" ->
                            NoThumbnail

                        fileUrl ->
                            Image fileUrl
                )
        , JD.null NoThumbnail
        ]
