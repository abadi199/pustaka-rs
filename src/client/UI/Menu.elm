module UI.Menu exposing
    ( Link
    , externalLink
    , internalLink
    , noLink
    , view
    )

import Element as E exposing (..)
import Html.Events exposing (..)
import Tree exposing (Tree)
import UI.Link as UI
import UI.Spacing as UI


view : Tree { text : String, link : Link msg, selected : Bool } -> Element msg
view items =
    column []
        (items
            |> Tree.map viewItem
            |> Tree.flatten
                (\level n c ->
                    column
                        [ if level == 0 then
                            UI.padding -5

                          else
                            UI.paddingEach
                                { top = -5
                                , right = -20
                                , bottom = -20
                                , left = -5
                                }
                        ]
                        (n ++ c)
                )
        )


viewItem : { text : String, link : Link msg, selected : Bool } -> List (Element msg)
viewItem item =
    case item.link of
        External url ->
            [ E.link [] { url = url, label = text item.text } ]

        Internal msg url ->
            [ UI.link [] { url = url, label = text item.text, msg = msg } ]

        NoLink ->
            [ el [] (text item.text) ]


externalLink : String -> Link msg
externalLink url =
    External url


internalLink : (String -> msg) -> String -> Link msg
internalLink msg url =
    Internal msg url


noLink : Link msg
noLink =
    NoLink


type Link msg
    = Internal (String -> msg) String
    | External String
    | NoLink
