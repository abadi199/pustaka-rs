module UI.Menu exposing
    ( Link
    , externalLink
    , internalLink
    , noLink
    , view
    )

import Element as E exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (link)
import Tree exposing (Tree)


view : Tree { text : String, link : Link msg, selected : Bool } -> Element msg
view items =
    row []
        (items
            |> Tree.map viewItem
            |> Tree.flatten
                (\n c ->
                    row
                        []
                        (n ++ c)
                )
        )


viewItem : { text : String, link : Link msg, selected : Bool } -> List (Element msg)
viewItem item =
    case item.link of
        External url ->
            [ E.link [] { url = url, label = text item.text } ]

        Internal msg url ->
            [ E.link [] { url = url, label = text item.text } ]

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
