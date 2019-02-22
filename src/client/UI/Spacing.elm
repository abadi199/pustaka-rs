module UI.Spacing exposing (padding, spacing)

import Element as E exposing (Attribute, modular)


scaled : Int -> Int
scaled =
    modular 24 1.25 >> round


spacing : Int -> Attribute msg
spacing scale =
    E.spacing (scaled scale)


padding : Int -> Attribute msg
padding scale =
    E.padding (scaled scale)
