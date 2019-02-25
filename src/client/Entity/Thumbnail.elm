module Entity.Thumbnail exposing (Thumbnail, new, none, thumbnailDecoder, toUrl, url)

import File exposing (File)
import Json.Decode as JD


type Thumbnail
    = NoThumbnail
    | New File
    | Url String


none : Thumbnail
none =
    NoThumbnail


new : File -> Thumbnail
new =
    New


url : String -> Thumbnail
url =
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


toUrl : Thumbnail -> Maybe String
toUrl thumbnail =
    case thumbnail of
        NoThumbnail ->
            Nothing

        New _ ->
            Nothing

        Url fileUrl ->
            Just fileUrl
