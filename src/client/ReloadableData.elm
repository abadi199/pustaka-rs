module ReloadableData
    exposing
        ( ReloadableData(..)
        , ReloadableWebData
        , fromRemoteData
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


refresh : RemoteData e a -> ReloadableData e a -> ReloadableData e a
refresh remoteData reloadableData =
    case toMaybe reloadableData of
        Just old ->
            case remoteData of
                RemoteData.NotAsked ->
                    NotAsked

                RemoteData.Loading ->
                    Reloading old

                RemoteData.Success a ->
                    Success a

                RemoteData.Failure e ->
                    FailureWithData e old

        Nothing ->
            fromRemoteData remoteData
