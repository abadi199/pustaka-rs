module Entity.Publication exposing
    ( Data
    , Id
    , MetaData
    , Page
    , deleteThumbnail
    , downloadCover
    , downloadPage
    , emptyMetaData
    , get
    , getProgress
    , getRecentlyAdded
    , getRecentlyRead
    , id
    , idToInt
    , idToString
    , listByCategory
    , read
    , update
    , updateProgress
    , uploadThumbnail
    )

import Entity.Image as Image exposing (Image)
import Entity.MediaFormat as MediaFormat exposing (MediaFormat)
import Entity.Progress as Progress exposing (Progress)
import Entity.Thumbnail as Thumbnail exposing (Thumbnail, thumbnailDecoder)
import File exposing (File)
import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableWebData)
import ReloadableData.Http
import Task exposing (Task)


type Id
    = Id Int


id : Int -> Id
id =
    Id


idToString : Id -> String
idToString (Id i) =
    String.fromInt i


idToInt : Id -> Int
idToInt (Id i) =
    i



-- MODEL


type alias MetaData =
    { id : Int
    , isbn : String
    , title : String
    , file : String
    , mediaFormat : MediaFormat
    , thumbnail : Thumbnail
    }


emptyMetaData : MetaData
emptyMetaData =
    { id = -1
    , isbn = ""
    , title = ""
    , file = ""
    , mediaFormat = MediaFormat.none
    , thumbnail = Thumbnail.none
    }


type alias Data =
    { id : Int
    , isbn : String
    , title : String
    , thumbnail : Thumbnail
    , totalPages : Int
    , mediaFormat : MediaFormat
    }


type alias Page =
    { pageNumber : Int
    , url : String
    }



-- HTTP


getRecentlyAdded : { count : Int, categoryId : Int, msg : ReloadableWebData () (List MetaData) -> msg } -> Cmd msg
getRecentlyAdded { count, categoryId, msg } =
    ReloadableData.Http.get
        { initial = ()
        , url =
            "/api/publication/recently_added"
                ++ ("/category_id/" ++ String.fromInt categoryId)
                ++ ("/count/" ++ String.fromInt count)
        , msg = msg
        , decoder = JD.list metaDataDecoder
        }


getRecentlyRead : { count : Int, msg : ReloadableWebData () (List MetaData) -> msg } -> Cmd msg
getRecentlyRead { count, msg } =
    ReloadableData.Http.get
        { initial = ()
        , url = "/api/publication/recently_read/count/" ++ String.fromInt count
        , msg = msg
        , decoder = JD.list metaDataDecoder
        }


getProgress : { publicationId : Int, msg : ReloadableWebData Int Float -> msg } -> Cmd msg
getProgress { publicationId, msg } =
    ReloadableData.Http.get
        { initial = publicationId
        , url = "/api/publication/progress/" ++ String.fromInt publicationId
        , msg = msg
        , decoder = JD.float
        }


updateProgress : { publicationId : Int, progress : Progress, msg : ReloadableWebData Int () -> msg } -> Cmd msg
updateProgress { publicationId, progress, msg } =
    ReloadableData.Http.put
        { initial = publicationId
        , url = "/api/publication/progress/"
        , decoder = JD.succeed ()
        , json =
            JE.object
                [ ( "publication_id", JE.int publicationId )
                , ( "progress", JE.float <| Progress.toFloat progress )
                ]
        , msg = msg
        }


listByCategory : { categoryId : Int, msg : ReloadableWebData () (List MetaData) -> msg } -> Cmd msg
listByCategory { categoryId, msg } =
    ReloadableData.Http.get
        { initial = ()
        , url = "/api/publication/category/" ++ String.fromInt categoryId
        , msg = msg
        , decoder = JD.list metaDataDecoder
        }


get : { publicationId : Int, msg : ReloadableWebData Int MetaData -> msg } -> Cmd msg
get { publicationId, msg } =
    ReloadableData.Http.get
        { initial = publicationId
        , url = "/api/publication/" ++ String.fromInt publicationId
        , msg = msg
        , decoder = metaDataDecoder
        }


read : { publicationId : Int, msg : ReloadableWebData Int Data -> msg } -> Cmd msg
read { publicationId, msg } =
    ReloadableData.Http.get
        { initial = publicationId
        , url = "/api/publication/read/" ++ String.fromInt publicationId
        , msg = msg
        , decoder = decoder
        }


update : { publication : MetaData, msg : ReloadableWebData Int () -> msg } -> Cmd msg
update { publication, msg } =
    ReloadableData.Http.put
        { initial = publication.id
        , url = "/api/publication/"
        , decoder = JD.succeed ()
        , json = encode publication
        , msg = msg
        }


uploadThumbnail :
    { publicationId : Int
    , fileName : String
    , file : File
    , msg : ReloadableWebData () () -> msg
    }
    -> Cmd msg
uploadThumbnail { publicationId, fileName, file, msg } =
    ReloadableData.Http.upload
        { initial = ()
        , url = "/api/publication/thumbnail/" ++ String.fromInt publicationId
        , msg = msg
        , fileName = fileName
        , file = file
        , decoder = JD.succeed ()
        }


downloadCover : { publicationId : Int, msg : ReloadableWebData () Image -> msg } -> Cmd msg
downloadCover { publicationId, msg } =
    Image.get
        { url = "/api/publication/thumbnail/" ++ String.fromInt publicationId
        , msg = msg
        }


downloadPage : { publicationId : Int, page : Int, msg : ReloadableWebData () Image -> msg } -> Cmd msg
downloadPage { publicationId, page, msg } =
    Image.get
        { url = "/api/publication/read/" ++ String.fromInt publicationId ++ "/page/" ++ String.fromInt page
        , msg = msg
        }


deleteThumbnail : { publicationId : Int, msg : ReloadableWebData () () -> msg } -> Cmd msg
deleteThumbnail { publicationId, msg } =
    ReloadableData.Http.delete
        { initial = ()
        , url = "/api/publication/thumbnail/" ++ String.fromInt publicationId
        , msg = msg
        , json = JE.null
        }



-- DECODER


metaDataDecoder : JD.Decoder MetaData
metaDataDecoder =
    JD.map6 MetaData
        (JD.field "id" JD.int)
        (JD.field "isbn" JD.string)
        (JD.field "title" JD.string)
        (JD.field "file" JD.string)
        (JD.field "media_format" MediaFormat.decoder)
        (JD.field "thumbnail_url" thumbnailDecoder)


decoder : JD.Decoder Data
decoder =
    JD.map6 Data
        (JD.field "id" JD.int)
        (JD.field "isbn" JD.string)
        (JD.field "title" JD.string)
        (JD.field "thumbnail_url" thumbnailDecoder)
        (JD.field "total_pages" JD.int)
        (JD.field "media_format" MediaFormat.decoder)


pageDecoder : JD.Decoder Page
pageDecoder =
    JD.map2 Page
        (JD.field "page_number" JD.int)
        (JD.field "url" JD.string)



-- ENCODER


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
