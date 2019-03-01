module Reader exposing (PageView(..), getPageNumber)


type PageView
    = DoublePage Int
    | SinglePage Int


getPageNumber : PageView -> Int
getPageNumber pageView =
    case pageView of
        DoublePage pageNumber ->
            pageNumber

        SinglePage pageNumber ->
            pageNumber
