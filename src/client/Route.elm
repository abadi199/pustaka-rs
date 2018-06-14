module Route
    exposing
        ( Route(..)
        , categoryUrl
        , fromUrl
        )

import Url
import Url.Builder as Url
import Url.Parser as Parser exposing ((</>), Parser, int, s, top)


type Route
    = Home
    | Category Int
    | NotFound String


fromUrl : Url.Url -> Route
fromUrl url =
    case Parser.parse parser url of
        Nothing ->
            NotFound (Url.toString url)

        Just route ->
            route


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home <| s "app"
        , Parser.map Category <| s "category" </> int
        ]


categoryUrl : Int -> String
categoryUrl id =
    "/category/" ++ String.fromInt id
