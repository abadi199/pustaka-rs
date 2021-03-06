module UI.Nav.Side exposing
    ( SideNav
    , toHtml
    , view
    , withSearch
    )

import Assets exposing (Assets)
import Css exposing (..)
import Css.Transitions as Transitions exposing (transition)
import Entity.Category exposing (Category)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Tree
import UI.Css.Grid as Grid
import UI.Css.MediaQuery as MediaQuery
import UI.Error
import UI.Loading
import UI.Logo as Logo
import UI.Menu
import UI.Nav exposing (SelectedItem(..))
import UI.Parts.Search exposing (Search)
import UI.Spacing as Spacing


type SideNav msg
    = SideNav (List (Html msg))
    | SideNavWithSearch (Search msg) (List (Html msg))


toHtml : { assets : Assets, onLinkClick : String -> msg } -> SideNav msg -> Html msg
toHtml { assets, onLinkClick } sideNav =
    div
        [ css
            [ height (pct 100)
            , minHeight (vh 100)
            , Grid.display
            , Grid.templateRows [ "auto", "1fr" ]
            , Grid.rowGap 40
            , backgroundColor (rgba 0 0 0 0.125)
            , Spacing.padding Spacing.ExtraLarge
            ]
        ]
        (case sideNav of
            SideNav element ->
                Logo.full { assets = assets, homeUrl = Route.homeUrl, onLinkClick = onLinkClick } :: element

            SideNavWithSearch search element ->
                Logo.full { assets = assets, homeUrl = Route.homeUrl, onLinkClick = onLinkClick }
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


categoriesView : (String -> msg) -> SelectedItem -> List Category -> Html msg
categoriesView onLinkClicked selectedItem categories =
    div
        [ css [] ]
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
