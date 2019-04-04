module UI.Parts.Information exposing (panel)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import UI.Action as Action exposing (Action)
import UI.Background as Background
import UI.Card as Card
import UI.Heading as UI
import UI.List
import UI.Spacing as UI


type alias Description msg =
    { term : String, details : String, onClick : msg }


panel : { a | title : String, informationList : List (Description msg), actions : List (Action msg) } -> Html msg
panel { title, informationList, actions } =
    Card.simple
        [ css
            [ displayFlex
            , Background.transparentMediumBlack
            , width (pct 100)
            , UI.padding UI.Small
            ]
        ]
        [ div
            [ css
                [ width (pct 100)
                ]
            ]
            [ UI.heading 1 title
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
            [ displayFlex
            ]
        ]
        (actions |> List.map Action.toHtml)
