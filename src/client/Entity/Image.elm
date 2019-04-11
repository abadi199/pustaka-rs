module Entity.Image exposing
    ( Image(..)
    , ReloadableImage
    , fromBase64
    , fromBytes
    , get
    , none
    , toBase64
    )

import Base64.Encode
import Bytes exposing (Bytes)
import Bytes.Decode
import Json.Decode as JD
import ReloadableData exposing (ReloadableWebData)
import ReloadableData.Http


type alias ReloadableImage =
    ReloadableWebData () Image


type Image
    = Image String
    | Empty


none : Image
none =
    Empty


fromBase64 : String -> Image
fromBase64 base64 =
    Image base64


fromBytes : Bytes -> Image
fromBytes bytes =
    bytes
        |> Base64.Encode.bytes
        |> Base64.Encode.encode
        |> Image


toBase64 : Image -> Maybe String
toBase64 image =
    case image of
        Empty ->
            Nothing

        Image base64 ->
            Just base64


get : { url : String, msg : ReloadableWebData () Image -> msg } -> Cmd msg
get { msg, url } =
    ReloadableData.Http.download
        { initial = ()
        , url = url
        , msg = toImageMsg msg
        }


toImageMsg : (ReloadableWebData () Image -> msg) -> (ReloadableWebData () Bytes -> msg)
toImageMsg msg =
    \bytesData -> msg (ReloadableData.map fromBytes bytesData)
