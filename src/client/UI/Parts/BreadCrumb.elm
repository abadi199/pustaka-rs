module UI.Parts.BreadCrumb exposing (BreadCrumb, breadCrumb)

import Element as E exposing (..)


type alias BreadCrumb msg =
    { text : String, url : String, onClick : String -> msg }


breadCrumb : List (BreadCrumb msg) -> Element msg
breadCrumb breadcrumbs =
    text "Placeholder for Breadcrumb"
