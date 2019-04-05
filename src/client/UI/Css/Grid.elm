module UI.Css.Grid exposing
    ( area
    , columnEnd
    , columnGap
    , columnStart
    , display
    , rowGap
    , templateAreas
    , templateColumns
    , templateRows
    )

import Css exposing (Style, property)


area : String -> Style
area name =
    property "grid-area" name


templateAreas : List String -> Style
templateAreas areas =
    property "grid-template-areas" (areas |> List.map (\line -> "\"" ++ line ++ "\"") |> String.join " ")


display : Style
display =
    property "display" "grid"


templateRows : List String -> Style
templateRows rows =
    property "grid-template-rows" (rows |> String.join " ")


templateColumns : List String -> Style
templateColumns columns =
    property "grid-template-columns" (columns |> String.join " ")


columnStart : Int -> Style
columnStart index =
    property "grid-column-start" (String.fromInt index)


columnEnd : Int -> Style
columnEnd index =
    property "grid-column-end" (String.fromInt index)


rowGap : Int -> Style
rowGap gap =
    property "grid-row-gap" (String.fromInt gap ++ "px")


columnGap : Int -> Style
columnGap gap =
    property "grid-column-gap" (String.fromInt gap ++ "px")
