module UI.Loading exposing (view)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import UI.Background
import UI.Icon as Icon


view : Html msg
view =
    div
        [ css
            [ displayFlex
            , justifyContent center
            , alignItems center
            , width (pct 100)
            , height (pct 100)
            , position absolute
            , top (px 0)
            , left (px 0)
            , UI.Background.transparentHeavyWhite
            ]
        ]
        [ div
            [ css [ displayFlex, alignItems center ]
            ]
            [ Icon.spinner Icon.large ]
        ]
