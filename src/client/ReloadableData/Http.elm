module ReloadableData.Http exposing (delete, get, post, put)

import Http
import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableWebData)


toReloadableWebData : i -> Result Http.Error a -> ReloadableWebData i a
toReloadableWebData i result =
    case result of
        Err err ->
            ReloadableData.Failure err i

        Ok data ->
            ReloadableData.Success data


get : i -> String -> (ReloadableWebData i a -> msg) -> JD.Decoder a -> Cmd msg
get i url msg decoder =
    Http.get url decoder
        |> Http.send (toReloadableWebData i >> msg)


post : i -> String -> (ReloadableWebData i a -> msg) -> JD.Decoder a -> JE.Value -> Cmd msg
post i url msg decoder json =
    Http.post url (Http.jsonBody json) decoder
        |> Http.send (toReloadableWebData i >> msg)


put : i -> String -> (ReloadableWebData i a -> msg) -> JD.Decoder a -> JE.Value -> Cmd msg
put i url msg decoder json =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = Http.jsonBody json
        , timeout = Nothing
        , withCredentials = False
        , expect = Http.expectJson decoder
        }
        |> Http.send (toReloadableWebData i >> msg)


delete : String -> (ReloadableWebData () () -> msg) -> JE.Value -> Cmd msg
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
        |> Http.send (toReloadableWebData () >> msg)
