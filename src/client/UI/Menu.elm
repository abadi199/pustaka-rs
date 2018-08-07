module UI.Menu
    exposing
        ( Link
        , externalLink
        , internalLink
        , noLink
        , view
        )

import Css exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (link)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Tree exposing (Tree)


view : Tree { text : String, link : Link msg, selected : Bool } -> Html msg
view items =
    nav []
        (items
            |> Tree.map viewItem
            |> Tree.flatten
                (\n c ->
                    ul
                        [ css
                            [ margin zero
                            , padding4 zero (rem 1) zero (rem 1)
                            ]
                        ]
                        (n ++ c)
                )
        )


viewItem : { text : String, link : Link msg, selected : Bool } -> List (Html msg)
viewItem item =
    let
        itemStyles =
            if item.selected then
                [ css
                    [ fontWeight bold
                    , cursor pointer
                    ]
                ]

            else
                [ css [ cursor pointer ] ]

        linkStyles =
            css [ color unset, textDecoration unset ]
    in
    [ li
        (itemStyles
            ++ [ css
                    [ listStyleType none
                    , padding zero
                    , margin zero
                    ]
               ]
        )
        (case item.link of
            External url ->
                [ a [ linkStyles, href url ] [ text item.text ] ]

            Internal msg url ->
                [ link msg [ linkStyles, href url ] [ text item.text ]
                ]

            NoLink ->
                [ span [ linkStyles ] [ text item.text ] ]
        )
    ]


externalLink : String -> Link msg
externalLink url =
    External url


internalLink : msg -> String -> Link msg
internalLink msg url =
    Internal msg url


noLink : Link msg
noLink =
    NoLink


type Link msg
    = Internal msg String
    | External String
    | NoLink
