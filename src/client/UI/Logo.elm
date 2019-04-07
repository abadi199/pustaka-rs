module UI.Logo exposing (full)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (alt, css, href, src)
import UI.Link as UI


full : { logoUrl : String, homeUrl : String, onLinkClick : String -> msg } -> Html msg
full { logoUrl, homeUrl, onLinkClick } =
    UI.link []
        { url = homeUrl
        , msg = onLinkClick
        , label = img [ css [ height (px 50) ], src logoUrl, alt "" ] []
        }
