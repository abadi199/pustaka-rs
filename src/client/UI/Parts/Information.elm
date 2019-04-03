module UI.Parts.Information exposing (panel)

import Entity.Publication as Publication
import Html.Styled as H exposing (..)
import Svg exposing (Svg)
import UI.Action as Action exposing (Action)
import UI.Background as Background
import UI.Card as Card
import UI.Heading as UI
import UI.List
import UI.Spacing as UI


type alias Description msg =
    { term : String, details : String, onClick : msg }


panel : { a | title : String, informationList : List (Description msg), actions : List (Action msg) } -> Element msg
panel { title, informationList, actions } =
    Card.simple
        [ alignTop
        , Background.transparentMediumBlack
        , width fill
        , UI.padding -2
        ]
        [ column
            [ UI.spacing -2
            , width fill
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


viewActions : List (Action msg) -> Element msg
viewActions actions =
    row
        [ alignBottom
        , alignRight
        , UI.spacing -5
        ]
        (actions |> List.map Action.toElement)
