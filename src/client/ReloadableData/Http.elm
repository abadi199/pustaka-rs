module ReloadableData.Http exposing
    ( delete
    , get
    , getTask
    , post
    , postTask
    , put
    , putTask
    )

import Http
import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Task exposing (Task)


toReloadableWebData : i -> Result Http.Error a -> ReloadableWebData i a
toReloadableWebData i result =
    case result of
        Err err ->
            ReloadableData.Failure err i

        Ok data ->
            ReloadableData.Success data


get : i -> String -> (ReloadableWebData i a -> msg) -> JD.Decoder a -> Cmd msg
get i url msg decoder =
    getRequest url decoder
        |> Http.send (toReloadableWebData i >> msg)


getTask : i -> String -> JD.Decoder a -> Task Never (ReloadableWebData i a)
getTask i url decoder =
    getRequest url decoder
        |> Http.toTask
        |> Task.andThen (\a -> Task.succeed (Success a))
        |> Task.onError (\err -> Task.succeed (Failure err i))


getRequest : String -> JD.Decoder a -> Http.Request a
getRequest url decoder =
    Http.get url decoder


post : i -> String -> (ReloadableWebData i a -> msg) -> JD.Decoder a -> JE.Value -> Cmd msg
post i url msg decoder json =
    Http.post url (Http.jsonBody json) decoder
        |> Http.send (toReloadableWebData i >> msg)


postTask : i -> String -> JD.Decoder a -> JE.Value -> Task Never (ReloadableWebData i a)
postTask i url decoder json =
    Http.post url (Http.jsonBody json) decoder
        |> Http.toTask
        |> Task.andThen (\a -> Task.succeed (Success a))
        |> Task.onError (\err -> Task.succeed (Failure err i))


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


putTask : i -> String -> JD.Decoder a -> JE.Value -> Task Never (ReloadableWebData i a)
putTask i url decoder json =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = Http.jsonBody json
        , timeout = Nothing
        , withCredentials = False
        , expect = Http.expectJson decoder
        }
        |> Http.toTask
        |> Task.andThen (\a -> Task.succeed (Success a))
        |> Task.onError (\err -> Task.succeed (Failure err i))


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
