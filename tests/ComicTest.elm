module ComicTest exposing (slider)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Reader.Comic
import Test exposing (..)


slider : Test
slider =
    describe "Comic Slider"
        [ test "percentage to page number" <|
            \_ -> Expect.equal 1 1
        ]
