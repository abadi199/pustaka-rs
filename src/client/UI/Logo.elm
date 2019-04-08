module UI.Logo exposing (full, text)

import Assets exposing (Assets)
import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (alt, css, href, src)
import UI.Link as UI


text :
    { assets : Assets
    , homeUrl : String
    , onLinkClick : String -> msg
    }
    -> Html msg
text { assets, homeUrl, onLinkClick } =
    UI.link [ css [ displayFlex, justifyContent center, alignItems center ] ]
        { url = homeUrl
        , msg = onLinkClick
        , label = img [ css [ height (px 30) ], src assets.logoText, alt "" ] []
        }


full :
    { assets : Assets
    , homeUrl : String
    , onLinkClick : String -> msg
    }
    -> Html msg
full { assets, homeUrl, onLinkClick } =
    UI.link [ css [ displayFlex, justifyContent center, alignItems center ] ]
        { url = homeUrl
        , msg = onLinkClick
        , label = img [ css [ height (px 50) ], src assets.logo, alt "" ] []
        }
