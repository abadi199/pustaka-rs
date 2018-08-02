module UI.Layout exposing (withSideNav)

import Browser
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UI.Nav.Side exposing (SideNav)
import UI.Parts.Search exposing (Search)


withSideNav : { title : String, sideNav : SideNav msg, content : List (Html msg) } -> Browser.Document msg
withSideNav { title, sideNav, content } =
    { title = title
    , body =
        [ div
            [ css
                [ Css.property "display" "grid"
                , Css.property "grid-template-columns" "auto 1fr"
                , Css.property "grid-template-rows" "100vh"
                , fontFamily sansSerif
                , backgroundColor (rgba 55 80 92 1)
                ]
            ]
            ((sideNav
                |> UI.Nav.Side.toHtml
             )
                :: [ div [ css [ padding (rem 2) ] ] content ]
            )
        ]
            |> List.map Html.Styled.toUnstyled
    }
