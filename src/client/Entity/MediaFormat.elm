module Entity.MediaFormat exposing (MediaFormat(..), decoder, encode, none, toString)

import Json.Decode as JD
import Json.Encode as JE


type MediaFormat
    = NoMediaFormat
    | CBR
    | CBZ
    | Epub


none : MediaFormat
none =
    NoMediaFormat


decoder : JD.Decoder MediaFormat
decoder =
    JD.string
        |> JD.andThen
            (\str ->
                case String.toLower str of
                    "cbr" ->
                        JD.succeed CBR

                    "cbz" ->
                        JD.succeed CBZ

                    "epub" ->
                        JD.succeed Epub

                    "" ->
                        JD.succeed NoMediaFormat

                    _ ->
                        JD.fail <| "Unknown Format " ++ str
            )


encode : MediaFormat -> JE.Value
encode mediaFormat =
    case mediaFormat of
        CBR ->
            JE.string "cbr"

        CBZ ->
            JE.string "cbz"

        Epub ->
            JE.string "epub"

        NoMediaFormat ->
            JE.string ""


toString : MediaFormat -> String
toString mediaFormat =
    case mediaFormat of
        CBR ->
            "cbr"

        CBZ ->
            "cbz"

        Epub ->
            "epub"

        NoMediaFormat ->
            ""
