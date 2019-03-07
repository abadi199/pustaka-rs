module Reader exposing
    ( PageView(..)
    , getPageNumber
    , nextPage
    , previousPage
    )


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


previousPage : PageView -> PageView
previousPage currentPage =
    case currentPage of
        DoublePage a ->
            DoublePage (a - 2)

        SinglePage a ->
            SinglePage (a - 1)


nextPage : PageView -> PageView
nextPage currentPage =
    case currentPage of
        DoublePage a ->
            DoublePage (a + 2)

        SinglePage a ->
            SinglePage (a + 1)
