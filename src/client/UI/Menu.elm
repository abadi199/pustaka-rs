module UI.Menu
    exposing
        ( Link
        , externalLink
        , internalLink
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (link)
import Tree exposing (Tree)


view : Tree { text : String, link : Link msg, selected : Bool } -> Html msg
view items =
    nav []
        (items
            |> Tree.map viewItem
            |> Tree.flatten (\n c -> ul [] (n ++ c))
        )


viewItem : { text : String, link : Link msg, selected : Bool } -> List (Html msg)
viewItem item =
    let
        itemStyles =
            if item.selected then
                [ style "font-weight" "bold"
                , style "cursor" "pointer"
                ]

            else
                [ style "cursor" "pointer" ]
    in
    [ li itemStyles
        (case item.link of
            External url ->
                [ a [ href url ] [ text item.text ] ]

            Internal msg url ->
                [ link msg [ href url ] [ text item.text ]
                ]
        )
    ]


externalLink : String -> Link msg
externalLink url =
    External url


internalLink : msg -> String -> Link msg
internalLink msg url =
    Internal msg url


type Link msg
    = Internal msg String
    | External String
