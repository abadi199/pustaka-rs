module Route exposing
    ( browseByCategoryUrl
    , browseByMediaTypeUrl
    , categoryUrl
    , homeUrl
    , publicationUrl
    , readUrl
    )

import Parser exposing ((|.), (|=))
import Url
import Url.Builder as Url
import Url.Parser as UrlParser exposing ((</>), Parser, int, s, top)


baseUrl : String
baseUrl =
    "/app"


homeUrl : String
homeUrl =
    baseUrl


categoryUrl : Int -> String
categoryUrl id =
    baseUrl ++ "/category/" ++ String.fromInt id


publicationUrl : Int -> String
publicationUrl id =
    baseUrl ++ "/pub/" ++ String.fromInt id


readUrl : Int -> String
readUrl id =
    baseUrl ++ "/read/" ++ String.fromInt id


browseByCategoryUrl : String
browseByCategoryUrl =
    baseUrl ++ "/categories"


browseByMediaTypeUrl : String
browseByMediaTypeUrl =
    baseUrl ++ "/media-types"
