module ReloadableData.Http exposing
    ( delete
    , get
    , image
    , post
    , put
    , upload
    )

import Bytes exposing (Bytes)
import File exposing (File)
import Http
import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Task exposing (Task)
import UI.Image exposing (Image)



-- CMD


get :
    { initial : i
    , url : String
    , msg : ReloadableWebData i a -> msg
    , decoder : JD.Decoder a
    }
    -> Cmd msg
get { initial, url, msg, decoder } =
    Http.get
        { url = url
        , expect = Http.expectJson (toResultMsg initial msg) decoder
        }


type Base64
    = Base64 String


image :
    { initial : i
    , url : String
    , msg : ReloadableWebData i Image -> msg
    }
    -> Cmd msg
image { initial, url, msg } =
    Http.get
        { url = url
        , expect = Http.expectBytesResponse (toResultMsg initial msg) toImage
        }


post :
    { initial : i
    , url : String
    , msg : ReloadableWebData i a -> msg
    , decoder : JD.Decoder a
    , json : JE.Value
    }
    -> Cmd msg
post { initial, url, msg, decoder, json } =
    Http.post
        { url = url
        , body = Http.jsonBody json
        , expect = Http.expectJson (toResultMsg initial msg) decoder
        }


put :
    { initial : i
    , url : String
    , msg : ReloadableWebData i a -> msg
    , decoder : JD.Decoder a
    , json : JE.Value
    }
    -> Cmd msg
put { initial, url, msg, decoder, json } =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = Http.jsonBody json
        , timeout = Nothing
        , expect = Http.expectJson (toResultMsg initial msg) decoder
        , tracker = Nothing
        }


delete :
    { initial : i
    , url : String
    , msg : ReloadableWebData i () -> msg
    , json : JE.Value
    }
    -> Cmd msg
delete { initial, url, msg, json } =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = Http.jsonBody json
        , timeout = Nothing
        , expect = Http.expectWhatever (toResultMsg initial msg)
        , tracker = Nothing
        }


upload :
    { initial : i
    , url : String
    , msg : ReloadableWebData i a -> msg
    , fileName : String
    , file : File
    , decoder : JD.Decoder a
    }
    -> Cmd msg
upload { initial, url, msg, fileName, file, decoder } =
    Http.post
        { url = url
        , body = Http.multipartBody [ Http.filePart fileName file ]
        , expect = Http.expectJson (toResultMsg initial msg) decoder
        }



-- MISC


toReloadableWebData : i -> Result Http.Error a -> ReloadableWebData i a
toReloadableWebData i result =
    case result of
        Err err ->
            ReloadableData.Failure err i

        Ok data ->
            ReloadableData.Success i data


toResultMsg : i -> (ReloadableWebData i a -> msg) -> (Result Http.Error a -> msg)
toResultMsg i msg =
    \result -> msg (toReloadableWebData i result)


toImage : Http.Response Bytes -> Result Http.Error Image
toImage response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.BadStatus_ metadata bytes ->
            Err (Http.BadStatus metadata.statusCode)

        Http.GoodStatus_ metadata bytes ->
            Ok <| UI.Image.image bytes
