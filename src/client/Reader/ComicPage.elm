module Reader.ComicPage exposing
    ( ComicPage(..)
    , calculatePageNumber
    , empty
    , map
    , toLeftPage
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


toLeftPage : a -> { totalPages : Int, percentage : Float } -> ComicPage a
toLeftPage a ({ totalPages, percentage } as args) =
    let
        page =
            calculatePageNumber args
    in
    if page == 0 then
        Empty

    else if page >= totalPages then
        OutOfBound

    else if page < 0 then
        OutOfBound

    else if (page |> remainderBy 2) == 0 then
        Page (page - 1) a

    else
        Page page a


toRightPage : a -> { totalPages : Int, percentage : Float } -> ComicPage a
toRightPage a ({ totalPages, percentage } as args) =
    let
        page =
            calculatePageNumber args
    in
    if page >= totalPages then
        OutOfBound

    else if page < 0 then
        OutOfBound

    else if (page |> remainderBy 2) == 0 then
        Page page a

    else if page == totalPages - 1 then
        Empty

    else
        Page (page + 1) a


map : (a -> b) -> ComicPage a -> ComicPage b
map f page =
    case page of
        Empty ->
            Empty

        Page i a ->
            Page i (f a)

        OutOfBound ->
            OutOfBound
