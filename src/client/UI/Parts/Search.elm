module UI.Parts.Search exposing (Search, toElement, view)

import Css exposing (..)
import Css.Global
import Css.Transitions
import Element as E exposing (..)
import Element.Input as Input


type Search msg
    = Search (Element msg)


type State
    = State { focused : Bool, value : String }


toElement : Search msg -> Element msg
toElement (Search element) =
    element


view : (String -> msg) -> String -> Search msg
view msg value =
    Input.text []
        { onChange = msg
        , text = value
        , placeholder = Nothing
        , label = Input.labelAbove [] (text "Search")
        }
        |> Search
