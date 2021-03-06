module Route exposing
    ( browseByCategoryIdUrl
    , browseByCategoryUrl
    , browseByMediaTypeUrl
    , categoryUrl
    , homeUrl
    , publicationEditUrl
    , publicationUrl
    , readUrl
    )

import Parser exposing ((|.), (|=))
import Url
import Url.Builder as Url
import Url.Parser as UrlParser exposing ((</>), Parser, int, s, top)


baseUrl : String
baseUrl =
    ""


homeUrl : String
homeUrl =
    baseUrl ++ "/"


categoryUrl : Int -> String
categoryUrl id =
    baseUrl ++ "/category/" ++ String.fromInt id


publicationUrl : Int -> String
publicationUrl id =
    baseUrl ++ "/pub/" ++ String.fromInt id


publicationEditUrl : Int -> String
publicationEditUrl id =
    baseUrl ++ "/pub/edit/" ++ String.fromInt id


readUrl : Int -> String
readUrl id =
    baseUrl ++ "/read/" ++ String.fromInt id


browseByCategoryUrl : String
browseByCategoryUrl =
    baseUrl ++ "/categories"


browseByCategoryIdUrl : Int -> String
browseByCategoryIdUrl categoryId =
    browseByCategoryUrl ++ "/" ++ String.fromInt categoryId


browseByMediaTypeUrl : String
browseByMediaTypeUrl =
    baseUrl ++ "/media-types"
