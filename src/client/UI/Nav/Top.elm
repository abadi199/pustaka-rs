module UI.Nav.Top exposing
    ( State
    , TopNav
    , initialState
    , toHtml
    , view
    , withSearch
    )

import Assets exposing (Assets)
import Browser.Navigation as Nav
import Css exposing (..)
import Css.Transitions as Transitions exposing (transition)
import Entity.Category exposing (Category)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events as HE exposing (onClick)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Tree
import UI.Error
import UI.Loading
import UI.Logo as Logo
import UI.Menu
import UI.Nav exposing (SelectedItem(..))
import UI.Parts.Search exposing (Search)
import UI.Spacing as Spacing


type State msg
    = State (StateData msg)


type alias StateData msg =
    { menu : MenuState msg }


initialState : State msg
initialState =
    State { menu = Closed }


type MenuState msg
    = Opened
    | Closed


toggleMenu : MenuState msg -> MenuState msg
toggleMenu state =
    case state of
        Opened ->
            Closed

        Closed ->
            Opened


type TopNav msg
    = TopNav (List (Html msg))
    | TopNavWithSearch (Search msg) (List (Html msg))


onLinkClick : Nav.Key -> State msg -> (State msg -> Cmd msg -> msg) -> (String -> msg)
onLinkClick key state onStateChange =
    \url -> onStateChange state (Nav.pushUrl key url)


toHtml :
    { key : Nav.Key
    , assets : Assets
    , onStateChange : State msg -> Cmd msg -> msg
    , state : State msg
    }
    -> TopNav msg
    -> Html msg
toHtml { key, assets, onStateChange, state } sideNav =
    let
        (State stateData) =
            state

        logo =
            div
                [ css
                    [ width (pct 100)
                    , backgroundColor (rgba 224 224 224 1)
                    , displayFlex
                    , flexDirection column
                    , justifyContent center
                    , alignItems center
                    , Spacing.padding Spacing.Medium
                    , Spacing.marginBottom Spacing.Large
                    , zIndex (int 2)
                    , position relative
                    ]
                ]
                [ Logo.text
                    { assets = assets
                    , homeUrl = Route.homeUrl
                    , onLinkClick = onLinkClick key state onStateChange
                    }
                ]
    in
    div
        [ css
            [ width (pct 100)
            , position relative
            ]
        ]
        (case sideNav of
            TopNav element ->
                logo :: [ mobileMenuIcon state onStateChange assets, mobileMenu state element ]

            TopNavWithSearch search element ->
                logo :: [ mobileMenuIcon state onStateChange assets, mobileMenu state element ]
        )


mobileMenu : State msg -> List (Html msg) -> Html msg
mobileMenu (State stateData) element =
    div
        [ css
            ([ position absolute
             , right (px 0)
             , width (pct 100)
             , backgroundColor (rgba 224 224 224 1)
             , transition [ Transitions.transform 500 ]
             , boxShadow5 (px 0) (px 0) (px 10) (px 10) (rgba 0 0 0 0.25)
             , paddingLeft (px 100)
             , zIndex (int 1)
             , top (pct 100)
             ]
                ++ (case stateData.menu of
                        Closed ->
                            [ transform (translateY (pct -100)) ]

                        Opened ->
                            []
                   )
            )
        ]
        element


mobileMenuIcon : State msg -> (State msg -> Cmd msg -> msg) -> Assets -> Html msg
mobileMenuIcon (State stateData) onStateChange assets =
    img
        [ HA.src assets.menuIcon
        , HA.alt "Menu"
        , css
            [ Css.height (px 70)
            , position absolute
            , top (px 0)
            , left (px 20)
            , zIndex (int 3)
            ]
        , onClick (onStateChange (State { stateData | menu = toggleMenu stateData.menu }) Cmd.none)
        ]
        []


withSearch : Search msg -> TopNav msg -> TopNav msg
withSearch search sideNav =
    case sideNav of
        TopNav element ->
            TopNavWithSearch search element

        TopNavWithSearch _ _ ->
            sideNav


view : (String -> msg) -> SelectedItem -> ReloadableWebData () (List Category) -> TopNav msg
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
        |> TopNav


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
