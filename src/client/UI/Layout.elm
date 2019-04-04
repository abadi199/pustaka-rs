module UI.Layout exposing (withSideNav)

import Browser
import Css exposing (..)
import Css.Global as Global exposing (global)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import UI.Nav.Side exposing (SideNav)
import UI.Parts.Dialog as Dialog exposing (Dialog)
import UI.Spacing as UI


reset : Html msg
reset =
    global
        [ Global.html
            [ boxSizing borderBox
            , fontSize (px 18)
            , fontFamilies [ "Source Sans Pro", "sans-serif" ]
            , fontWeight normal
            ]
        , Global.selector "*, *:before, *:after"
            [ boxSizing inherit
            , margin zero
            , padding zero
            , fontSize (Css.em 1)
            ]
        , Global.body [ margin zero, padding zero ]
        ]


withSideNav :
    { title : String
    , sideNav : SideNav msg
    , content : Html msg
    , dialog : Dialog msg
    }
    -> Browser.Document msg
withSideNav { title, sideNav, content, dialog } =
    { title = title
    , body =
        [ H.toUnstyled <| reset
        , H.toUnstyled <|
            div
                [ css
                    [ displayFlex
                    , minWidth (vw 100)
                    , minHeight (vh 100)
                    , position relative
                    ]
                ]
                [ viewDialog dialog
                , div
                    [ css
                        [ minWidth (pct 100)
                        , minHeight (pct 100)
                        , displayFlex
                        , flexDirection row
                        ]
                    ]
                    ((sideNav |> UI.Nav.Side.toHtml)
                        :: [ div
                                [ css
                                    [ width (pct 100)
                                    , height (pct 100)
                                    , UI.padding 1
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
