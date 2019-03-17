module Entity.Thumbnail exposing
    ( Thumbnail(..)
    , fromUrl
    , hasThumbnail
    , new
    , none
    , thumbnailDecoder
    )

import Entity.Image as Image exposing (Image)
import File exposing (File)
import Json.Decode as JD


type Thumbnail
    = NoThumbnail
    | New File
    | Url String


hasThumbnail : Thumbnail -> Bool
hasThumbnail thumbnail =
    case thumbnail of
        NoThumbnail ->
            False

        New _ ->
            False

        Url _ ->
            True


none : Thumbnail
none =
    NoThumbnail


new : File -> Thumbnail
new =
    New


fromUrl : String -> Thumbnail
fromUrl =
    Url


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
                            Url fileUrl
                )
        , JD.null NoThumbnail
        ]
