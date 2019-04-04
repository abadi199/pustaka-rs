module UI.Menu exposing
    ( Link
    , externalLink
    , internalLink
    , noLink
    , view
    )

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events exposing (..)
import Tree exposing (Tree)
import UI.Link as UI
import UI.Spacing as UI


view : Tree { text : String, link : Link msg, selected : Bool } -> Html msg
view items =
    div [ css [ displayFlex, flexDirection column ] ]
        (items
            |> Tree.map viewItem
            |> Tree.flatten
                (\level n c ->
                    div
                        [ css
                            [ displayFlex
                            , flexDirection column
                            , if level == 0 then
                                UI.padding 5

                              else
                                UI.paddingEach
                                    { top = 5
                                    , right = 20
                                    , bottom = 20
                                    , left = 5
                                    }
                            ]
                        ]
                        (n ++ c)
                )
        )


viewItem : { text : String, link : Link msg, selected : Bool } -> List (Html msg)
viewItem item =
    case item.link of
        External url ->
            [ a [ HA.href url ] [ text item.text ] ]

        Internal msg url ->
            [ UI.link [] { url = url, label = text item.text, msg = msg } ]

        NoLink ->
            [ div [] [ text item.text ] ]


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
