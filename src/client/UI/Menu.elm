module UI.Menu
    exposing
        ( Action
        , click
        , link
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


view : List { text : String, action : Action msg, selected : Bool } -> Html msg
view items =
    nav []
        [ ul []
            (items
                |> List.map
                    (\item ->
                        let
                            itemStyles =
                                if item.selected then
                                    [ style "font-weight" "bold"
                                    , style "cursor" "pointer"
                                    ]

                                else
                                    [ style "cursor" "pointer" ]
                        in
                        case item.action of
                            Link url ->
                                li itemStyles
                                    [ a [ href url ] [ text item.text ] ]

                            Click msg ->
                                li
                                    (onClick msg :: itemStyles)
                                    [ text item.text ]
                    )
            )
        ]


link : String -> Action msg
link url =
    Link url


click : msg -> Action msg
click msg =
    Click msg


type Action msg
    = Link String
    | Click msg
