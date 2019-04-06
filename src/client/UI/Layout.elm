module UI.Layout exposing (withNav)

import Browser
import Css exposing (..)
import Css.Global as Global exposing (global)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import UI.Css.Grid as Grid
import UI.Css.MediaQuery as MediaQuery
import UI.Nav.Side exposing (SideNav)
import UI.Nav.Top exposing (TopNav)
import UI.Parts.Dialog as Dialog exposing (Dialog)
import UI.Reset exposing (reset)
import UI.Spacing as Spacing


withNav :
    { title : String
    , logoUrl : String
    , sideNav : SideNav msg
    , topNav : TopNav msg
    , content : Html msg
    , dialog : Dialog msg
    }
    -> Browser.Document msg
withNav { title, logoUrl, sideNav, topNav, content, dialog } =
    let
        viewSideNav =
            div
                [ css
                    [ display none
                    , MediaQuery.forTabletLandscapeUp [ display block ]
                    ]
                ]
                [ sideNav |> UI.Nav.Side.toHtml logoUrl ]

        viewTopNav =
            div
                [ css
                    [ flexGrow (int 1)
                    , display block
                    , MediaQuery.forTabletLandscapeUp [ display none ]
                    ]
                ]
                [ topNav |> UI.Nav.Top.toHtml logoUrl ]
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
                [ viewDialog dialog
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
