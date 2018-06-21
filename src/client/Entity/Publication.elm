module Entity.Publication
    exposing
        ( Publication
        , decoder
        , listByCategory
        )

import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableWebData)
import ReloadableData.Http


type alias Publication =
    { id : Int
    , isbn : String
    , title : String
    }


listByCategory : Int -> (ReloadableWebData (List Publication) -> msg) -> Cmd msg
listByCategory categoryId msg =
    ReloadableData.Http.get
        ("/api/publication/category/" ++ String.fromInt categoryId)
        msg
        (JD.list decoder)


decoder : JD.Decoder Publication
decoder =
    JD.map3 Publication
        (JD.field "id" JD.int)
        (JD.field "isbn" JD.string)
        (JD.field "title" JD.string)
