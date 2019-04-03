module UI.Action exposing
    ( Action
    , clickable
    , compact
    , disable
    , large
    , link
    , toElement
    )

import Html.Styled as H exposing (..)
import Html.Styled.Events as HE
import UI.Icon exposing (Icon)
import UI.Link as UI
import UI.Spacing as Spacing


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


toElement : Action msg -> Element msg
toElement action =
    case action of
        CompactAction data ->
            viewCompact data

        LargeAction data ->
            viewLarge data


viewCompact : ActionType msg -> Element msg
viewCompact actionType =
    case actionType of
        Link { text, icon, url, onClick } ->
            UI.link [ pointer ] { url = url, msg = onClick, label = icon }

        Clickable { text, icon, onClick } ->
            el [ pointer, EV.onClick onClick ] icon

        Disable { text, icon } ->
            el [] icon


viewLarge : ActionType msg -> Element msg
viewLarge actionType =
    case actionType of
        Link { text, icon, url, onClick } ->
            UI.link [ pointer ] { url = url, msg = onClick, label = row [] [ icon, E.text text ] }

        Clickable { text, icon, onClick } ->
            row
                [ Spacing.paddingEach { top = -10, bottom = -10, right = -2, left = -2 }
                , Border.width 1
                , Border.solid
                , Border.color (rgba 0 0 0 0.5)
                , pointer
                , EV.onClick onClick
                ]
                [ icon, E.text text ]

        Disable { text, icon } ->
            row [] [ icon, E.text text ]
