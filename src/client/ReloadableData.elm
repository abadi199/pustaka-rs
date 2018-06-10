module ReloadableData
    exposing
        ( ReloadableData(..)
        , ReloadableWebData
        , fromRemoteData
        , map
        , refresh
        , toMaybe
        )

import Http
import RemoteData exposing (RemoteData)


type alias ReloadableWebData a =
    ReloadableData Http.Error a


type ReloadableData e a
    = NotAsked
    | Loading
    | Reloading a
    | Success a
    | Failure e
    | FailureWithData e a


fromRemoteData : RemoteData e a -> ReloadableData e a
fromRemoteData remoteData =
    case remoteData of
        RemoteData.NotAsked ->
            NotAsked

        RemoteData.Loading ->
            Loading

        RemoteData.Success a ->
            Success a

        RemoteData.Failure e ->
            Failure e


toMaybe : ReloadableData e a -> Maybe a
toMaybe reloadableData =
    case reloadableData of
        Success a ->
            Just a

        Reloading a ->
            Just a

        FailureWithData e a ->
            Just a

        NotAsked ->
            Nothing

        Loading ->
            Nothing

        Failure _ ->
            Nothing


refresh : ReloadableData e a -> ReloadableData e a -> ReloadableData e a
refresh prev next =
    case toMaybe prev of
        Just prevData ->
            case next of
                NotAsked ->
                    NotAsked

                Reloading a ->
                    Reloading a

                Loading ->
                    Reloading prevData

                Success a ->
                    Success a

                Failure e ->
                    FailureWithData e prevData

                FailureWithData e a ->
                    FailureWithData e a

        Nothing ->
            next


map : (a -> b) -> ReloadableData e a -> ReloadableData e b
map f reloadableData =
    case reloadableData of
        Success a ->
            Success (f a)

        Reloading a ->
            Reloading (f a)

        FailureWithData e a ->
            FailureWithData e (f a)

        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failure e ->
            Failure e
