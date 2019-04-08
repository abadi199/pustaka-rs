module UI.Layout exposing (State, initialState, withNav)

import Assets exposing (Assets)
import Browser
import Browser.Navigation as Nav
import Css exposing (..)
import Entity.Category as Category exposing (Category)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import ReloadableData exposing (ReloadableWebData)
import UI.Css.MediaQuery as MediaQuery
import UI.Nav exposing (SelectedItem)
import UI.Nav.Side exposing (SideNav)
import UI.Nav.Top exposing (TopNav)
import UI.Parts.Dialog as Dialog exposing (Dialog)
import UI.Parts.Search
import UI.Reset exposing (reset)
import UI.Spacing as Spacing


type State msg
    = State (StateData msg)


initialState : State msg
initialState =
    State
        { searchText = ""
        , selectedItem = UI.Nav.NoSelection
        , dialog = Dialog.none
        , topNavState = UI.Nav.Top.initialState
        }


type alias StateData msg =
    { searchText : String
    , selectedItem : SelectedItem
    , dialog : Dialog msg
    , topNavState : UI.Nav.Top.State msg
    }


onLinkClick : Nav.Key -> State msg -> (State msg -> Cmd msg -> msg) -> (String -> msg)
onLinkClick key (State stateData) onStateChange =
    \url -> onStateChange (State stateData) (Nav.pushUrl key url)


onSearch : State msg -> (State msg -> Cmd msg -> msg) -> (String -> msg)
onSearch (State stateData) onStateChange =
    \searchText -> onStateChange (State { stateData | searchText = searchText }) Cmd.none


withNav :
    { key : Nav.Key
    , title : String
    , assets : Assets
    , content : Html msg
    , categories : ReloadableWebData () (List Category)
    , state : State msg
    , onStateChange : State msg -> Cmd msg -> msg
    }
    -> Browser.Document msg
withNav { key, assets, title, content, categories, state, onStateChange } =
    let
        (State stateData) =
            state

        onTopNavStateChange topNavState cmd =
            onStateChange (State { stateData | topNavState = topNavState }) cmd

        viewSideNav =
            div
                [ css
                    [ display none
                    , MediaQuery.forTabletLandscapeUp [ display block ]
                    ]
                ]
                [ categories
                    |> UI.Nav.Side.view (onLinkClick key state onStateChange) stateData.selectedItem
                    |> UI.Nav.Side.withSearch (UI.Parts.Search.view (onSearch state onStateChange) stateData.searchText)
                    |> UI.Nav.Side.toHtml { assets = assets, onLinkClick = onLinkClick key state onStateChange }
                ]

        viewTopNav =
            div
                [ css
                    [ flexGrow (int 1)
                    , display block
                    , MediaQuery.forTabletLandscapeUp [ display none ]
                    ]
                ]
                [ categories
                    |> UI.Nav.Top.view (onLinkClick key state onStateChange) stateData.selectedItem
                    |> UI.Nav.Top.withSearch (UI.Parts.Search.view (onSearch state onStateChange) stateData.searchText)
                    |> UI.Nav.Top.toHtml
                        { key = key
                        , assets = assets
                        , onStateChange = onTopNavStateChange
                        , state = stateData.topNavState
                        }
                ]
    in
    { title = title
    , body =
        [ H.toUnstyled <| reset
        , H.toUnstyled <|
            div
                [ css
                    [ displayFlex
                    , width (vw 100)
                    , minHeight (vh 100)
                    , position relative
                    , overflowX hidden
                    ]
                ]
                [ viewDialog stateData.dialog
                , div
                    [ css
                        [ width (pct 100)
                        , minHeight (pct 100)
                        , displayFlex
                        , flexWrap wrap
                        , overflowX hidden
                        , MediaQuery.forTabletLandscapeUp [ flexWrap noWrap ]
                        ]
                    ]
                    (viewSideNav
                        :: viewTopNav
                        :: [ div
                                [ css
                                    [ height (pct 100)
                                    , width (pct 100)
                                    , Spacing.padding Spacing.Large
                                    , overflowX hidden
                                    ]
                                ]
                                [ content ]
                           ]
                    )
                ]
        ]
    }


viewDialog : Dialog msg -> Html msg
viewDialog dialog =
    Dialog.toHtml dialog
