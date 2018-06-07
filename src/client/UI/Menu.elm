module UI.Menu exposing (view)

import Html exposing (..)


view : List ( String, String ) -> Html msg
view items =
    nav []
        [ ul []
            (items
                |> List.map (\( item, url ) -> li [] [ text item ])
            )
        ]
