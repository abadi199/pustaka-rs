module UI.Layout exposing (withSideNav)

import Browser
import Html.Styled as H exposing (..)
import UI.Nav.Side exposing (SideNav)
import UI.Parts.Dialog as Dialog exposing (Dialog)
import UI.Parts.Search exposing (Search)
import UI.Spacing as UI


withSideNav : { title : String, sideNav : SideNav msg, content : Element msg, dialog : Dialog msg } -> Browser.Document msg
withSideNav { title, sideNav, content, dialog } =
    { title = title
    , body =
        [ layout [ inFront (viewDialog dialog) ] <|
            E.row
                [ width fill
                , height fill
                ]
                ((sideNav |> UI.Nav.Side.toElement)
                    :: [ el
                            [ width fill
                            , height fill
                            , UI.padding 1
                            ]
                            content
                       ]
                )
        ]
    }


viewDialog : Dialog msg -> Html msg
viewDialog dialog =
    Dialog.toElement dialog
