module Entity.Publication exposing
    ( Data
    , MediaFormat(..)
    , MetaData
    , Page
    , get
    , listByCategory
    , read
    )

import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableWebData)
import ReloadableData.Http
import Task exposing (Task)


type alias MetaData =
    { id : Int
    , isbn : String
    , title : String
    , thumbnail : Maybe String
    }


type alias Data =
    { id : Int
    , isbn : String
    , title : String
    , thumbnail : Maybe String
    , totalPages : Int
    , currentPages : List Page
    , mediaFormat : MediaFormat
    }


type MediaFormat
    = CBR
    | CBZ
    | Epub


type alias Page =
    { pageNumber : Int
    , url : String
    }


listByCategory : Int -> (ReloadableWebData () (List MetaData) -> msg) -> Cmd msg
listByCategory categoryId msg =
    ReloadableData.Http.get
        ()
        ("/api/publication/category/" ++ String.fromInt categoryId)
        msg
        (JD.list metaDecoder)


get : Int -> Task Never (ReloadableWebData Int MetaData)
get publicationId =
    ReloadableData.Http.getTask
        publicationId
        ("/api/publication/" ++ String.fromInt publicationId)
        metaDecoder


read : Int -> Task Never (ReloadableWebData Int Data)
read publicationId =
    ReloadableData.Http.getTask
        publicationId
        ("/api/publication/read/" ++ String.fromInt publicationId)
        decoder


metaDecoder : JD.Decoder MetaData
metaDecoder =
    JD.map4 MetaData
        (JD.field "id" JD.int)
        (JD.field "isbn" JD.string)
        (JD.field "title" JD.string)
        (JD.field "thumbnail_url" (JD.maybe JD.string))


decoder : JD.Decoder Data
decoder =
    JD.map7 Data
        (JD.field "id" JD.int)
        (JD.field "isbn" JD.string)
        (JD.field "title" JD.string)
        (JD.field "thumbnail_url" (JD.maybe JD.string))
        (JD.field "total_pages" JD.int)
        (JD.maybe (JD.field "pages" (JD.list pageDecoder)) |> JD.map (Maybe.withDefault []))
        (JD.field "media_format" mediaFormatDecoder)


mediaFormatDecoder : JD.Decoder MediaFormat
mediaFormatDecoder =
    JD.string
        |> JD.andThen
            (\str ->
                case String.toUpper str of
                    "CBR" ->
                        JD.succeed CBR

                    "CBZ" ->
                        JD.succeed CBZ

                    "EPUB" ->
                        JD.succeed Epub

                    _ ->
                        JD.fail <| "Unknown Format " ++ str
            )


pageDecoder : JD.Decoder Page
pageDecoder =
    JD.map2 Page
        (JD.field "page_number" JD.int)
        (JD.field "url" JD.string)
