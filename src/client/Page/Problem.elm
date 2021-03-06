module Page.Problem exposing (view)

import Browser
import Html


view : String -> Browser.Document msg
view text =
    { title = "Pustaka - Error"
    , body = [ Html.text text ]
    }
