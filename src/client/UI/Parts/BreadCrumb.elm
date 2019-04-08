module UI.Parts.BreadCrumb exposing (BreadCrumb, breadCrumb)

import Html.Styled as H exposing (..)


type alias BreadCrumb msg =
    { text : String, url : String, onClick : String -> msg }


breadCrumb : List (BreadCrumb msg) -> Html msg
breadCrumb breadcrumbs =
    text "Placeholder for Breadcrumb"
