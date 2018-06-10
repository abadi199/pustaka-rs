module ReloadableData.Http exposing (delete, get, post, put)

import Http
import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableWebData)


toReloadableWebData : Result Http.Error a -> ReloadableWebData a
toReloadableWebData result =
    case result of
        Err err ->
            ReloadableData.Failure err

        Ok data ->
            ReloadableData.Success data


get : String -> (ReloadableWebData a -> msg) -> JD.Decoder a -> Cmd msg
get url msg decoder =
    Http.get url decoder
        |> Http.send (toReloadableWebData >> msg)


post : String -> (ReloadableWebData a -> msg) -> JD.Decoder a -> JE.Value -> Cmd msg
post url msg decoder json =
    Http.post url (Http.jsonBody json) decoder
        |> Http.send (toReloadableWebData >> msg)


put : String -> (ReloadableWebData a -> msg) -> JD.Decoder a -> JE.Value -> Cmd msg
put url msg decoder json =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = Http.jsonBody json
        , timeout = Nothing
        , withCredentials = False
        , expect = Http.expectJson decoder
        }
        |> Http.send (toReloadableWebData >> msg)


delete : String -> (ReloadableWebData () -> msg) -> JE.Value -> Cmd msg
delete url msg json =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = Http.jsonBody json
        , timeout = Nothing
        , withCredentials = False
        , expect = Http.expectStringResponse (\_ -> Ok ())
        }
        |> Http.send (toReloadableWebData >> msg)
