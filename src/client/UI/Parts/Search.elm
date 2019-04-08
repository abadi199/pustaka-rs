module UI.Parts.Search exposing (Search, toElement, view)

import Css exposing (..)
import Css.Global
import Css.Transitions
import Html.Styled as H exposing (..)


type Search msg
    = Search (Html msg)


type State
    = State { focused : Bool, value : String }


toElement : Search msg -> Html msg
toElement (Search element) =
    element


view : (String -> msg) -> String -> Search msg
view msg value =
    Search (text "UI.Parts.Search.view")



-- Input.text []
--     { onChange = msg
--     , text = value
--     , placeholder = Nothing
--     , label = Input.labelAbove [] (text "Search")
--     }
--     |> Search
