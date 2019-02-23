module UI.Action exposing (Action, compact, large, toElement)

import Element as E exposing (..)
import UI.Icon exposing (Icon)
import UI.Spacing as Spacing


type Action msg
    = CompactAction (ActionData msg)
    | LargeAction (ActionData msg)


type alias ActionData msg =
    { text : String, icon : Icon msg, onClick : msg }


compact : { text : String, icon : Icon msg, onClick : msg } -> Action msg
compact =
    CompactAction


large : { text : String, icon : Icon msg, onClick : msg } -> Action msg
large =
    LargeAction


toElement : Action msg -> Element msg
toElement action =
    case action of
        CompactAction data ->
            viewCompact data

        LargeAction data ->
            viewLarge data


viewCompact : ActionData msg -> Element msg
viewCompact { text, icon, onClick } =
    el [] icon


viewLarge : ActionData msg -> Element msg
viewLarge { text, icon, onClick } =
    row [] [ icon, E.text text ]
