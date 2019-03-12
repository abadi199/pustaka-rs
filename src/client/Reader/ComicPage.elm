module Reader.ComicPage exposing
    ( ComicPage(..)
    , calculatePageNumber
    , empty
    , map
    , toLeftPage
    , toMaybe
    , toPageNumber
    , toRightPage
    )


type ComicPage a
    = Empty
    | Page Int a
    | OutOfBound


empty : ComicPage a
empty =
    Empty


toMaybe : ComicPage a -> Maybe a
toMaybe page =
    case page of
        Page _ a ->
            Just a

        Empty ->
            Nothing

        OutOfBound ->
            Nothing


toPageNumber : ComicPage a -> Maybe Int
toPageNumber page =
    case page of
        Page pageNumber _ ->
            Just pageNumber

        Empty ->
            Nothing

        OutOfBound ->
            Nothing


calculatePageNumber : { totalPages : Int, percentage : Float } -> Int
calculatePageNumber { totalPages, percentage } =
    toFloat (totalPages - 1)
        * (percentage / 100)
        |> round


toLeftPage : a -> (a -> a) -> { totalPages : Int, percentage : Float } -> (ComicPage a -> ComicPage a)
toLeftPage default f ({ totalPages, percentage } as args) =
    let
        page =
            calculatePageNumber args
    in
    if page == 0 then
        \_ -> Empty

    else if page >= totalPages then
        \_ -> OutOfBound

    else if page < 0 then
        \_ -> OutOfBound

    else if (page |> remainderBy 2) == 0 then
        \oldPage ->
            oldPage
                |> toMaybe
                |> Maybe.withDefault default
                |> (\a -> Page (page - 1) (f a))

    else
        \oldPage ->
            oldPage
                |> toMaybe
                |> Maybe.withDefault default
                |> (\a -> Page page (f a))


toRightPage : a -> (a -> a) -> { totalPages : Int, percentage : Float } -> (ComicPage a -> ComicPage a)
toRightPage default f ({ totalPages, percentage } as args) =
    let
        page =
            calculatePageNumber args
    in
    if page >= totalPages then
        \_ -> OutOfBound

    else if page < 0 then
        \_ -> OutOfBound

    else if (page |> remainderBy 2) == 0 then
        \oldPage ->
            oldPage
                |> toMaybe
                |> Maybe.withDefault default
                |> (\a -> Page page (f a))

    else if page == totalPages - 1 then
        \_ -> Empty

    else
        \oldPage ->
            oldPage
                |> toMaybe
                |> Maybe.withDefault default
                |> (\a -> Page (page + 1) (f a))


map : (a -> b) -> ComicPage a -> ComicPage b
map f page =
    case page of
        Empty ->
            Empty

        Page i a ->
            Page i (f a)

        OutOfBound ->
            OutOfBound
