module UI.Spacing exposing (padding, paddingEach, spacing)

import Element as E exposing (Attribute, modular)


scaled : Int -> Int
scaled n =
    if n == 0 then
        0

    else
        n |> modular 50 1.25 |> round


spacing : Int -> Attribute msg
spacing scale =
    E.spacing (scaled scale)


padding : Int -> Attribute msg
padding scale =
    paddingEach
        { top = scale
        , bottom = scale
        , right = scale
        , left = scale
        }


paddingEach : { top : Int, right : Int, bottom : Int, left : Int } -> Attribute msg
paddingEach { top, right, bottom, left } =
    E.paddingEach
        { top = scaled top
        , bottom = scaled bottom
        , left = scaled left
        , right = scaled right
        }
