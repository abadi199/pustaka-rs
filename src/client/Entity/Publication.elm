module Entity.Publication
    exposing
        ( Data
        , MetaData
        , Page
        , decoder
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
        (JD.list decoder)


get : Int -> Task Never (ReloadableWebData Int MetaData)
get publicationId =
    ReloadableData.Http.getTask
        publicationId
        ("/api/publication/" ++ String.fromInt publicationId)
        decoder


read : Int -> Task Never (ReloadableWebData Int Data)
read publicationId =
    ReloadableData.Http.getTask
        publicationId
        ("/api/publication/read/" ++ String.fromInt publicationId)
        openedDecoder


decoder : JD.Decoder MetaData
decoder =
    JD.map4 MetaData
        (JD.field "id" JD.int)
        (JD.field "isbn" JD.string)
        (JD.field "title" JD.string)
        (JD.field "thumbnail_url" (JD.maybe JD.string))


openedDecoder : JD.Decoder Data
openedDecoder =
    JD.map6 Data
        (JD.field "id" JD.int)
        (JD.field "isbn" JD.string)
        (JD.field "title" JD.string)
        (JD.field "thumbnail_url" (JD.maybe JD.string))
        (JD.field "total_pages" JD.int)
        (JD.field "pages" (JD.list pageDecoder))


pageDecoder : JD.Decoder Page
pageDecoder =
    JD.map2 Page
        (JD.field "page_number" JD.int)
        (JD.field "url" JD.string)
