module ReloadableData.Http exposing
    ( delete
    , get
    , post
    , put
    , upload
    )

import File exposing (File)
import Http
import Json.Decode as JD
import Json.Encode as JE
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Task exposing (Task)



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
    let
        _ =
            Debug.log "File.mime" (File.mime file)
    in
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
