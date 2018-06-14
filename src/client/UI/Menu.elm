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


view : List ( String, Action msg ) -> Html msg
view items =
    nav []
        [ ul []
            (items
                |> List.map
                    (\( item, action ) ->
                        case action of
                            Link url ->
                                li []
                                    [ a [ href url ] [ text item ] ]

                            Click msg ->
                                li [ onClick msg ] [ text item ]
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
