module Entity.Thumbnail exposing
    ( Thumbnail(..)
    , hasThumbnail
    , new
    , none
    , thumbnail
    , thumbnailDecoder
    )

import File exposing (File)
import Json.Decode as JD


type Thumbnail
    = NoThumbnail
    | New File
    | Thumbnail


hasThumbnail : Thumbnail -> Bool
hasThumbnail t =
    case t of
        NoThumbnail ->
            False

        New _ ->
            False

        Thumbnail ->
            True


none : Thumbnail
none =
    NoThumbnail


new : File -> Thumbnail
new =
    New


thumbnail : Thumbnail
thumbnail =
    Thumbnail


thumbnailDecoder : JD.Decoder Thumbnail
thumbnailDecoder =
    JD.oneOf
        [ JD.bool
            |> JD.map
                (\has ->
                    case has of
                        False ->
                            NoThumbnail

                        True ->
                            Thumbnail
                )
        , JD.null NoThumbnail
        ]
