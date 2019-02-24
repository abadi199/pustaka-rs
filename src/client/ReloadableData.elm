module ReloadableData exposing
    ( ReloadableData(..)
    , ReloadableWebData
    , error
    , join
    , loading
    , map
    , refresh
    , setError
    , toMaybe
    )

import Http


type alias ReloadableWebData i a =
    ReloadableData Http.Error i a


type ReloadableData e i a
    = NotAsked i
    | Loading i
    | Reloading i a
    | Success i a
    | Failure e i
    | FailureWithData e i a


loading : ReloadableData e i a -> ReloadableData e i a
loading reloadableData =
    let
        i =
            initial reloadableData
    in
    reloadableData
        |> toMaybe
        |> Maybe.map (Reloading i)
        |> Maybe.withDefault (Loading i)


join : Result a a -> a
join result =
    case result of
        Ok a ->
            a

        Err a ->
            a


toMaybe : ReloadableData e i a -> Maybe a
toMaybe reloadableData =
    case reloadableData of
        Success i a ->
            Just a

        Reloading i a ->
            Just a

        FailureWithData e i a ->
            Just a

        NotAsked _ ->
            Nothing

        Loading _ ->
            Nothing

        Failure _ _ ->
            Nothing


refresh : ReloadableData e i a -> ReloadableData e i a -> ReloadableData e i a
refresh prev next =
    case toMaybe prev of
        Just prevData ->
            case next of
                NotAsked i ->
                    NotAsked i

                Reloading i a ->
                    Reloading i a

                Loading i ->
                    Reloading i prevData

                Success i a ->
                    Success i a

                Failure e i ->
                    FailureWithData e i prevData

                FailureWithData e i a ->
                    FailureWithData e i a

        Nothing ->
            next


map : (a -> b) -> ReloadableData e i a -> ReloadableData e i b
map f reloadableData =
    case reloadableData of
        Success i a ->
            Success i (f a)

        Reloading i a ->
            Reloading i (f a)

        FailureWithData e i a ->
            FailureWithData e i (f a)

        NotAsked i ->
            NotAsked i

        Loading i ->
            Loading i

        Failure e i ->
            Failure e i


initial : ReloadableData e i a -> i
initial reloadableData =
    case reloadableData of
        Success i _ ->
            i

        Reloading i _ ->
            i

        FailureWithData _ i _ ->
            i

        NotAsked i ->
            i

        Loading i ->
            i

        Failure _ i ->
            i


error : ReloadableData e i a -> Maybe e
error reloadableData =
    case reloadableData of
        Success _ _ ->
            Nothing

        Reloading _ _ ->
            Nothing

        FailureWithData e _ _ ->
            Just e

        NotAsked _ ->
            Nothing

        Loading _ ->
            Nothing

        Failure e _ ->
            Just e


setError : e -> ReloadableData e i a -> ReloadableData e i a
setError e reloadableData =
    let
        i =
            initial reloadableData
    in
    reloadableData
        |> toMaybe
        |> Maybe.map (\data -> FailureWithData e i data)
        |> Maybe.withDefault (Failure e i)
