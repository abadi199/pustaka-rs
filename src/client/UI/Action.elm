module UI.Action exposing
    ( Action
    , clickable
    , compact
    , disable
    , large
    , link
    , toHtml
    )

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events as HE
import UI.Css.Grid as Grid
import UI.Icon exposing (Icon)
import UI.Link as UI
import UI.Spacing as UI


type Action msg
    = CompactAction (ActionType msg)
    | LargeAction (ActionType msg)


type ActionType msg
    = Link { text : String, icon : Icon msg, url : String, onClick : String -> msg }
    | Clickable { text : String, icon : Icon msg, onClick : msg }
    | Disable { text : String, icon : Icon msg }


link : { text : String, icon : Icon msg, url : String, onClick : String -> msg } -> ActionType msg
link =
    Link


clickable : { text : String, icon : Icon msg, onClick : msg } -> ActionType msg
clickable =
    Clickable


disable : { text : String, icon : Icon msg } -> ActionType msg
disable =
    Disable


compact : ActionType msg -> Action msg
compact =
    CompactAction


large : ActionType msg -> Action msg
large =
    LargeAction


toHtml : Action msg -> Html msg
toHtml action =
    case action of
        CompactAction data ->
            viewCompact data

        LargeAction data ->
            viewLarge data


viewCompact : ActionType msg -> Html msg
viewCompact actionType =
    case actionType of
        Link { text, icon, url, onClick } ->
            UI.link
                [ css [ cursor pointer ]
                ]
                { url = url, msg = onClick, label = icon }

        Clickable { text, icon, onClick } ->
            div
                [ css
                    [ cursor pointer
                    ]
                , HE.onClick onClick
                ]
                [ icon ]

        Disable { text, icon } ->
            div [] [ icon ]


viewLarge : ActionType msg -> Html msg
viewLarge actionType =
    case actionType of
        Link { text, icon, url, onClick } ->
            UI.link [ css [ cursor pointer ] ]
                { url = url
                , msg = onClick
                , label =
                    div
                        [ css
                            [ border3 (px 1) solid (rgba 0 0 0 0.25)
                            , Grid.display
                            , Grid.templateColumns [ "auto", "auto" ]
                            , Grid.columnGap 10
                            , UI.paddingEach
                                { top = UI.Small
                                , bottom = UI.Small
                                , left = UI.Large
                                , right = UI.Large
                                }
                            ]
                        ]
                        [ icon, H.text text ]
                }

        Clickable { text, icon, onClick } ->
            div
                [ css
                    [ cursor pointer
                    , displayFlex
                    , border3 (px 1) solid (rgba 0 0 0 0.25)
                    ]
                , HE.onClick onClick
                ]
                [ icon, H.text text ]

        Disable { text, icon } ->
            div [] [ icon, H.text text ]
