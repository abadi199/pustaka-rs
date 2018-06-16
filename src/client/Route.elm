module Route
    exposing
        ( Route(..)
        , categoryUrl
        , fromUrl
        , selectedCategories
        )

import Parser exposing ((|.), (|=))
import Url
import Url.Builder as Url
import Url.Parser as UrlParser exposing ((</>), Parser, int, s, top)


type Route
    = Home
    | Category (List Int)
    | NotFound String


fromUrl : Url.Url -> Route
fromUrl url =
    case UrlParser.parse parser url of
        Nothing ->
            NotFound (Url.toString url)

        Just route ->
            route


parser : Parser (Route -> a) a
parser =
    UrlParser.oneOf
        [ UrlParser.map Home <| s "app"
        , UrlParser.map (List.singleton >> Category) <| s "category" </> int
        ]


categoryUrl : Int -> String
categoryUrl id =
    "/category/" ++ String.fromInt id


selectedCategories : Route -> List Int
selectedCategories route =
    case route of
        Category categories ->
            categories

        _ ->
            []
