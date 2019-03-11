module ComicTest exposing (leftPage)

import Entity.MediaFormat as MediaFormat
import Entity.Publication as Publication
import Entity.Thumbnail as Thumbnail
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Reader.Comic
import ReloadableData
import Test exposing (..)


publication : Publication.Data
publication =
    { id = 1
    , isbn = "ISBN"
    , title = "Title"
    , thumbnail = Thumbnail.none
    , totalPages = 100
    , mediaFormat = MediaFormat.CBR
    }


model : Reader.Comic.Model
model =
    Reader.Comic.initialModel publication


leftPage : Test
leftPage =
    describe "Comic progress suite"
        [ test "at 0% of 5 pages" <|
            \_ ->
                Reader.Comic.toLeftPage { totalPages = 5, percentage = 0 }
                    |> Expect.equal Reader.Comic.Empty
        , test "at 100% of 5 pages" <|
            \_ ->
                Reader.Comic.toLeftPage { totalPages = 5, percentage = 100 }
                    |> Expect.equal (Reader.Comic.Page 3)
        , test "at 100% of 6 pages" <|
            \_ ->
                Reader.Comic.toLeftPage { totalPages = 6, percentage = 100 }
                    |> Expect.equal (Reader.Comic.Page 5)
        , test "at 50% of 5 pages" <|
            \_ ->
                Reader.Comic.toLeftPage { totalPages = 5, percentage = 50 }
                    |> Expect.equal (Reader.Comic.Page 1)
        , test "at 50% of 6 pages" <|
            \_ ->
                Reader.Comic.toLeftPage { totalPages = 6, percentage = 50 }
                    |> Expect.equal (Reader.Comic.Page 3)
        ]
