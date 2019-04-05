module UI.Layout exposing (withSideNav)

import Browser
import Css exposing (..)
import Css.Global as Global exposing (global)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import UI.Nav.Side exposing (SideNav)
import UI.Parts.Dialog as Dialog exposing (Dialog)
import UI.Reset exposing (reset)
import UI.Spacing as Spacing


withSideNav :
    { title : String
    , logoUrl : String
    , sideNav : SideNav msg
    , content : Html msg
    , dialog : Dialog msg
    }
    -> Browser.Document msg
withSideNav { title, logoUrl, sideNav, content, dialog } =
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
                        , flexDirection row
                        , overflowX hidden
                        ]
                    ]
                    ((sideNav |> UI.Nav.Side.toHtml logoUrl)
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
