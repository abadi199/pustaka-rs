module ComicTest exposing (leftPage, rightPage, updateProgress)

import Entity.MediaFormat as MediaFormat
import Entity.Publication as Publication
import Entity.Thumbnail as Thumbnail
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Reader.Comic as Comic
import Reader.ComicPage as ComicPage
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


model : Comic.Model
model =
    Comic.initialModel publication


leftPage : Test
leftPage =
    describe "left page test"
        [ test "at 0% of 5 pages" <|
            \_ ->
                ComicPage.toLeftPage () { totalPages = 5, percentage = 0 }
                    |> Expect.equal ComicPage.Empty
        , test "at 100% of 5 pages" <|
            \_ ->
                ComicPage.toLeftPage () { totalPages = 5, percentage = 100 }
                    |> Expect.equal (ComicPage.Page 3 ())
        , test "at 100% of 6 pages" <|
            \_ ->
                ComicPage.toLeftPage () { totalPages = 6, percentage = 100 }
                    |> Expect.equal (ComicPage.Page 5 ())
        , test "at 50% of 5 pages" <|
            \_ ->
                ComicPage.toLeftPage () { totalPages = 5, percentage = 50 }
                    |> Expect.equal (ComicPage.Page 1 ())
        , test "at 50% of 6 pages" <|
            \_ ->
                ComicPage.toLeftPage () { totalPages = 6, percentage = 50 }
                    |> Expect.equal (ComicPage.Page 3 ())
        , test "at 110% of 6 pages" <|
            \_ ->
                ComicPage.toLeftPage () { totalPages = 6, percentage = 110 }
                    |> Expect.equal ComicPage.OutOfBound
        ]


rightPage : Test
rightPage =
    describe "right page test"
        [ test "at 0% of 5 pages" <|
            \_ ->
                ComicPage.toRightPage () { totalPages = 5, percentage = 0 }
                    |> Expect.equal (ComicPage.Page 0 ())
        , test "at 100% of 5 pages" <|
            \_ ->
                ComicPage.toRightPage () { totalPages = 5, percentage = 100 }
                    |> Expect.equal (ComicPage.Page 4 ())
        , test "at 100% of 6 pages" <|
            \_ ->
                ComicPage.toRightPage () { totalPages = 6, percentage = 100 }
                    |> Expect.equal ComicPage.Empty
        , test "at 50% of 5 pages" <|
            \_ ->
                ComicPage.toRightPage () { totalPages = 5, percentage = 50 }
                    |> Expect.equal (ComicPage.Page 2 ())
        , test "at 50% of 6 pages" <|
            \_ ->
                ComicPage.toRightPage () { totalPages = 6, percentage = 50 }
                    |> Expect.equal (ComicPage.Page 4 ())
        , test "at 110% of 6 pages" <|
            \_ ->
                ComicPage.toRightPage () { totalPages = 6, percentage = 110 }
                    |> Expect.equal ComicPage.OutOfBound
        ]


updateProgress : Test
updateProgress =
    describe "update progress"
        [ test "left page at 0% of 5 pages" <|
            \_ ->
                let
                    ( updatedModel, cmd ) =
                        Comic.updateProgress { publication | totalPages = 5 }
                            model
                            (ReloadableData.Success 1 0)
                in
                Expect.equal updatedModel.leftPage ComicPage.empty
        , test "right page at 0% of 5 pages" <|
            \_ ->
                let
                    ( updatedModel, cmd ) =
                        Comic.updateProgress { publication | totalPages = 5 }
                            model
                            (ReloadableData.Success 1 0)
                in
                Expect.equal updatedModel.rightPage (ComicPage.Page 0 (ReloadableData.Loading ()))
        ]
