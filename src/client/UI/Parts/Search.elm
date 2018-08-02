module UI.Parts.Search exposing (Search, toHtml, view)

import Css exposing (..)
import Css.Global
import Css.Transitions
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)


type Search msg
    = Search (Html msg)


type State
    = State { focused : Bool, value : String }


toHtml : Search msg -> Html msg
toHtml (Search html) =
    html


view : (String -> msg) -> Search msg
view msg =
    let
        animationSpeed =
            100

        transitions =
            Css.Transitions.transition
                [ Css.Transitions.color animationSpeed
                , Css.Transitions.transform animationSpeed
                , Css.Transitions.padding animationSpeed
                , Css.Transitions.fontSize animationSpeed
                ]

        searchStyle =
            [ position relative
            , Css.property "display" "grid"
            ]

        labelStyle =
            [ position absolute
            , color (rgba 0 0 0 0.5)
            , Css.height (pct 100)
            , displayFlex
            , alignItems center
            , paddingLeft (px 16)
            , transitions
            , fontSize (px 20)
            ]

        floatLabelStyle =
            [ Css.Global.generalSiblings
                [ Css.Global.selector "span"
                    [ transform (translate3d zero (pct -25) zero)
                    , fontSize (px 12)
                    ]
                ]

            -- , paddingTop (Css.em 2)
            ]

        inputStyle =
            [ boxShadow5 inset (px 2) (px 2) (px 5) (rgba 0 0 0 0.5)
            , border zero
            , borderRadius zero
            , padding4 (px 20) (px 16) (px 10) (px 16)
            , transitions
            , fontSize (Css.em 1)
            , focus floatLabelStyle
            , pseudoClass "not(:placeholder-shown)" floatLabelStyle
            ]
    in
    label
        [ css searchStyle
        ]
        [ input
            [ type_ "text"
            , css inputStyle
            , placeholder " "
            ]
            []
        , span
            [ css labelStyle
            ]
            [ text "Search" ]
        ]
        |> Search
