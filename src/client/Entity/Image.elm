module Entity.Image exposing (get)

import Bytes
import Bytes.Decode
import Entity.Publication as Publication
import Json.Decode as JD
import ReloadableData exposing (ReloadableWebData)
import ReloadableData.Http
import UI.Image exposing (Image)


get : { publicationId : Int, page : Int, msg : ReloadableWebData Int Image -> msg } -> Cmd msg
get { publicationId, page, msg } =
    ReloadableData.Http.image
        { initial = page
        , url = "/api/publication/read/" ++ String.fromInt publicationId ++ "/page/" ++ String.fromInt page
        , msg = msg
        }
