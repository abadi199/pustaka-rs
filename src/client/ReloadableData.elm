module ReloadableData
    exposing
        ( ReloadableData(..)
        , ReloadableWebData
        , fromRemoteData
        , join
        , loading
        , map
        , refresh
        , toMaybe
        , toResult
        )

import Http
import RemoteData exposing (RemoteData)


type alias ReloadableWebData i a =
    ReloadableData Http.Error i a


type ReloadableData e i a
    = NotAsked i
    | Loading i
    | Reloading a
    | Success a
    | Failure e i
    | FailureWithData e a


loading : ReloadableData e i a -> ReloadableData e i a
loading remoteData =
    remoteData
        |> toResult
        |> Result.map Reloading
        |> Result.mapError Loading
        |> join


join : Result a a -> a
join result =
    case result of
        Ok a ->
            a

        Err a ->
            a


fromRemoteData : i -> RemoteData e a -> ReloadableData e i a
fromRemoteData i remoteData =
    case remoteData of
        RemoteData.NotAsked ->
            NotAsked i

        RemoteData.Loading ->
            Loading i

        RemoteData.Success a ->
            Success a

        RemoteData.Failure e ->
            Failure e i


toMaybe : ReloadableData e i a -> Maybe a
toMaybe reloadableData =
    case reloadableData of
        Success a ->
            Just a

        Reloading a ->
            Just a

        FailureWithData e a ->
            Just a

        NotAsked _ ->
            Nothing

        Loading _ ->
            Nothing

        Failure _ _ ->
            Nothing


toResult : ReloadableData e i a -> Result i a
toResult reloadableData =
    case reloadableData of
        Success a ->
            Ok a

        Reloading a ->
            Ok a

        FailureWithData e a ->
            Ok a

        NotAsked i ->
            Err i

        Loading i ->
            Err i

        Failure _ i ->
            Err i


refresh : ReloadableData e i a -> ReloadableData e i a -> ReloadableData e i a
refresh prev next =
    case toMaybe prev of
        Just prevData ->
            case next of
                NotAsked i ->
                    NotAsked i

                Reloading a ->
                    Reloading a

                Loading _ ->
                    Reloading prevData

                Success a ->
                    Success a

                Failure e _ ->
                    FailureWithData e prevData

                FailureWithData e a ->
                    FailureWithData e a

        Nothing ->
            next


map : (a -> b) -> ReloadableData e i a -> ReloadableData e i b
map f reloadableData =
    case reloadableData of
        Success a ->
            Success (f a)

        Reloading a ->
            Reloading (f a)

        FailureWithData e a ->
            FailureWithData e (f a)

        NotAsked i ->
            NotAsked i

        Loading i ->
            Loading i

        Failure e i ->
            Failure e i
