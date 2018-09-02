module UI.Nav.Side exposing (SideNav, toHtml, view, withSearch)

import Browser.Navigation as Nav
import Css exposing (..)
import Css.Global exposing (a, global)
import Entity.Category exposing (Category)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set exposing (Set)
import Tree
import UI.Error
import UI.Loading
import UI.Menu
import UI.Parts.Search exposing (Search)


type SideNav msg
    = SideNav (List (Html msg))
    | SideNavWithSearch (Search msg) (List (Html msg))


toHtml : SideNav msg -> Html msg
toHtml sideNav =
    div
        [ css
            [ backgroundColor (rgba 0 0 0 0.2)
            , color (rgba 255 255 255 1)
            , padding (rem 1)
            , boxShadow4 (px 2) (px 0) (px 10) (rgba 0 0 0 0.25)
            ]
        ]
        (case sideNav of
            SideNav html ->
                html

            SideNavWithSearch search html ->
                UI.Parts.Search.toHtml search :: html
        )


withSearch : Search msg -> SideNav msg -> SideNav msg
withSearch search sideNav =
    case sideNav of
        SideNav html ->
            SideNavWithSearch search html

        SideNavWithSearch _ _ ->
            sideNav


view : (String -> msg) -> Set Int -> ReloadableWebData () (List Category) -> SideNav msg
view onLinkClicked selectedCategoryIds data =
    (case data of
        NotAsked _ ->
            []

        Loading _ ->
            [ UI.Loading.view ]

        Reloading categories ->
            [ UI.Loading.view, categoriesView onLinkClicked selectedCategoryIds categories ]

        Success categories ->
            [ categoriesView onLinkClicked selectedCategoryIds categories ]

        Failure error _ ->
            [ UI.Error.view "Error" ]

        FailureWithData error categories ->
            [ categoriesView onLinkClicked selectedCategoryIds categories, UI.Error.view "Error" ]
    )
        |> SideNav


categoriesView : (String -> msg) -> Set Int -> List Category -> Html msg
categoriesView onLinkClicked selectedCategoryIds categories =
    div
        [ css
            [ marginTop (rem 4)
            , minWidth (px 300)
            , color (rgba 255 255 255 0.7)
            , Css.Global.descendants
                [ Css.Global.typeSelector "li"
                    [ margin2 (Css.em 0.5) zero ]
                ]
            , Css.Global.children
                [ Css.Global.typeSelector "nav"
                    [ Css.Global.children
                        [ Css.Global.typeSelector "ul"
                            [ padding zero
                            , Css.Global.children
                                [ Css.Global.typeSelector "li"
                                    [ margin3 (Css.em 2) zero (Css.em 1)
                                    , fontSize (px 20)
                                    , fontWeight bold
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
        [ UI.Menu.view
            [ Tree.node
                { text = "Home"
                , selected = False
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
                                , selected = Set.member category.id selectedCategoryIds
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
                    , selected = False
                    , link = UI.Menu.internalLink onLinkClicked Route.browseByCategoryUrl
                    }
                    []
                , Tree.node
                    { text = "By Media Type"
                    , selected = False
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
                    , selected = False
                    , link = UI.Menu.noLink
                    }
                    []
                ]
            ]
        ]
