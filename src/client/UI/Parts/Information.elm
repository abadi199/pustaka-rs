module UI.Parts.Information exposing (panel)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import UI.Action as Action exposing (Action)
import UI.Background as Background
import UI.Card as Card
import UI.Css.Grid as Grid
import UI.Css.MediaQuery as MediaQuery
import UI.Heading as UI exposing (Level(..))
import UI.List
import UI.Spacing as UI


type alias Description msg =
    { term : String, details : String, onClick : msg }


panel :
    { a
        | title : String
        , poster : Html msg
        , informationList : List (Description msg)
        , actions : List (Action msg)
    }
    -> Html msg
panel { title, poster, informationList, actions } =
    Card.simple
        [ css
            [ Grid.display
            , Grid.templateColumns [ "1fr" ]
            , MediaQuery.forTabletLandscapeUp
                [ Grid.templateColumns [ "auto", "1fr" ]
                ]
            , Grid.columnGap 20
            , Background.transparentMediumBlack
            , width (pct 100)
            , UI.padding UI.Large
            ]
        ]
        [ poster
        , div
            [ css
                [ width (pct 100)
                , Grid.display
                , Grid.rowGap 10
                ]
            ]
            [ UI.heading One title
            , UI.List.dl (informationList |> List.map viewDescription)
            , viewActions actions
            ]
        ]


viewDescription : Description msg -> ( UI.List.DT msg, UI.List.DD msg )
viewDescription { term, details, onClick } =
    ( UI.List.dt { term = term ++ ":", onClick = onClick }
    , UI.List.dd { details = details, onClick = onClick }
    )


viewActions : List (Action msg) -> Html msg
viewActions actions =
    div
        [ css
            [ Grid.display
            , Grid.templateColumns [ "auto", "auto" ]
            , Grid.columnGap 20
            , justifyContent flexEnd
            , borderTop3 (px 1) solid (rgba 0 0 0 0.25)
            , UI.padding UI.Large
            ]
        ]
        (actions |> List.map Action.toHtml)
