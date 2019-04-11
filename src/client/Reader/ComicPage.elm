module Reader.ComicPage exposing
    ( ComicPage(..)
    , calculatePageNumber
    , empty
    , set
    , toLeftPage
    , toMaybe
    , toPageNumber
    , toRightPage
    , toSinglePage
    )

import Entity.Image exposing (Image, ReloadableImage)
import ReloadableData exposing (ReloadableWebData)


type ComicPage
    = Empty
    | Page Int ReloadableImage
    | OutOfBound


empty : ComicPage
empty =
    Empty


toMaybe : ComicPage -> Maybe ReloadableImage
toMaybe page =
    case page of
        Page _ a ->
            Just a

        Empty ->
            Nothing

        OutOfBound ->
            Nothing


toPageNumber : ComicPage -> Maybe Int
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


toLeftPage : ReloadableImage -> (ReloadableImage -> ReloadableImage) -> { totalPages : Int, percentage : Float } -> (ComicPage -> ComicPage)
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


toRightPage : ReloadableImage -> (ReloadableImage -> ReloadableImage) -> { totalPages : Int, percentage : Float } -> (ComicPage -> ComicPage)
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


toSinglePage : ReloadableImage -> (ReloadableImage -> ReloadableImage) -> { totalPages : Int, percentage : Float } -> (ComicPage -> ComicPage)
toSinglePage default f ({ totalPages } as args) =
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

    else
        \oldPage ->
            oldPage
                |> toMaybe
                |> Maybe.withDefault default
                |> (\a -> Page page (f a))


set : ReloadableImage -> ComicPage -> ComicPage
set value page =
    case page of
        Empty ->
            Empty

        Page i a ->
            Page i value

        OutOfBound ->
            OutOfBound
