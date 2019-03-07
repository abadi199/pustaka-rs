module UI.Nav.Side exposing
    ( SelectedItem(..)
    , SideNav
    , toElement
    , view
    , withSearch
    )

import Browser.Navigation as Nav
import Css.Global exposing (a, global)
import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Entity.Category exposing (Category)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set exposing (Set)
import Tree
import UI.Css.Basics
import UI.Error
import UI.Loading
import UI.Logo as Logo
import UI.Menu
import UI.Parts.Search exposing (Search)


type SideNav msg
    = SideNav (List (Element msg))
    | SideNavWithSearch (Search msg) (List (Element msg))


type SelectedItem
    = NoSelection
    | Home
    | CategoryId Int
    | BrowseByCategory
    | BrowseByMediaType
    | Settings


toElement : SideNav msg -> Element msg
toElement sideNav =
    E.column
        [ alignTop
        , height fill
        , Background.color (rgba 0 0 0 0.125)
        , padding 20
        ]
        (case sideNav of
            SideNav element ->
                Logo.full :: element

            SideNavWithSearch search element ->
                Logo.full
                    -- :: UI.Parts.Search.toElement search
                    :: element
        )


withSearch : Search msg -> SideNav msg -> SideNav msg
withSearch search sideNav =
    case sideNav of
        SideNav element ->
            SideNavWithSearch search element

        SideNavWithSearch _ _ ->
            sideNav


view : (String -> msg) -> SelectedItem -> ReloadableWebData () (List Category) -> SideNav msg
view onLinkClicked selectedItem data =
    (case data of
        NotAsked _ ->
            []

        Loading _ ->
            [ UI.Loading.view ]

        Reloading _ categories ->
            [ UI.Loading.view, categoriesView onLinkClicked selectedItem categories ]

        Success _ categories ->
            [ categoriesView onLinkClicked selectedItem categories ]

        Failure error _ ->
            [ UI.Error.http error ]

        FailureWithData error _ categories ->
            [ categoriesView onLinkClicked selectedItem categories, UI.Error.http error ]
    )
        |> SideNav


isSelectedCategoryId : Int -> SelectedItem -> Bool
isSelectedCategoryId categoryId selectedItem =
    case selectedItem of
        CategoryId selectedCategoryId ->
            categoryId == selectedCategoryId

        _ ->
            False


categoriesView : (String -> msg) -> SelectedItem -> List Category -> Element msg
categoriesView onLinkClicked selectedItem categories =
    E.column
        []
        [ UI.Menu.view
            [ Tree.node
                { text = "Home"
                , selected = selectedItem == Home
                , link =
                    UI.Menu.internalLink
                        onLinkClicked
                        Route.homeUrl
                }
                []
            , Tree.node
                { text = "Favorites"
                , selected = False
                , link = UI.Menu.noLink
                }
                (categories
                    |> List.map
                        (\category ->
                            Tree.node
                                { text = category.name
                                , selected = isSelectedCategoryId category.id selectedItem
                                , link =
                                    UI.Menu.internalLink
                                        onLinkClicked
                                        (Route.categoryUrl category.id)
                                }
                                []
                        )
                )
            , Tree.node
                { text = "Browse"
                , selected = False
                , link = UI.Menu.noLink
                }
                [ Tree.node
                    { text = "By Category"
                    , selected = selectedItem == BrowseByCategory
                    , link = UI.Menu.internalLink onLinkClicked Route.browseByCategoryUrl
                    }
                    []
                , Tree.node
                    { text = "By Media Type"
                    , selected = selectedItem == BrowseByMediaType
                    , link = UI.Menu.internalLink onLinkClicked Route.browseByMediaTypeUrl
                    }
                    []
                ]
            , Tree.node
                { text = "Manage"
                , selected = False
                , link = UI.Menu.noLink
                }
                [ Tree.node
                    { text = "Settings"
                    , selected = selectedItem == Settings
                    , link = UI.Menu.noLink
                    }
                    []
                ]
            ]
        ]
