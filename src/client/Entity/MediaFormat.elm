module Entity.MediaFormat exposing (MediaFormat(..), decoder, encode, none, toString)

import Json.Decode as JD
import Json.Encode as JE


type MediaFormat
    = NoMediaFormat
    | CBR
    | CBZ
    | Epub
    | Pdf


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

                    "pdf" ->
                        JD.succeed Pdf

                    "epub" ->
                        JD.succeed Epub

                    "" ->
                        JD.succeed NoMediaFormat

                    _ ->
                        JD.fail <| "Unknown Format " ++ str
            )


encode : MediaFormat -> JE.Value
encode mediaFormat =
    JE.string <| toString mediaFormat

toString : MediaFormat -> String
toString mediaFormat =
    case mediaFormat of
        CBR ->
            "cbr"

        CBZ ->
            "cbz"

        Pdf ->
            "pdf"

        Epub ->
            "epub"

        NoMediaFormat ->
            ""
