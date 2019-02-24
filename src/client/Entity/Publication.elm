module Entity.Publication exposing
    ( Data
    , MetaData
    , Page
    , emptyMetaData
    , get
    , listByCategory
    , read
    , update
    )

import Entity.MediaFormat as MediaFormat exposing (MediaFormat)
import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableWebData)
import ReloadableData.Http
import Task exposing (Task)


type alias MetaData =
    { id : Int
    , isbn : String
    , title : String
    , file : String
    , mediaFormat : MediaFormat
    , thumbnail : Maybe String
    }


emptyMetaData : MetaData
emptyMetaData =
    { id = -1
    , isbn = ""
    , title = ""
    , file = ""
    , mediaFormat = MediaFormat.none
    , thumbnail = Nothing
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


update : MetaData -> Task Never (ReloadableWebData Int ())
update publication =
    ReloadableData.Http.putTask
        publication.id
        "/api/publication/"
        (JD.succeed ())
        (encode publication)


metaDecoder : JD.Decoder MetaData
metaDecoder =
    JD.map6 MetaData
        (JD.field "id" JD.int)
        (JD.field "isbn" JD.string)
        (JD.field "title" JD.string)
        (JD.field "file" JD.string)
        (JD.field "media_format" MediaFormat.decoder)
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
        (JD.field "media_format" MediaFormat.decoder)


pageDecoder : JD.Decoder Page
pageDecoder =
    JD.map2 Page
        (JD.field "page_number" JD.int)
        (JD.field "url" JD.string)


encode : MetaData -> JE.Value
encode metaData =
    JE.object
        [ ( "id", JE.int metaData.id )
        , ( "title", JE.string metaData.title )
        , ( "isbn", JE.string metaData.isbn )
        , ( "media_type_id", JE.int 1 )
        , ( "media_format", MediaFormat.encode metaData.mediaFormat )
        , ( "author_id", JE.int 1 )
        , ( "thumbnail", JE.null )
        , ( "file", JE.string metaData.file )
        ]
