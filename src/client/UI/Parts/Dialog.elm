module UI.Parts.Dialog exposing
    ( Dialog
    , DialogType
    , confirmation
    , modal
    , none
    , toElement
    )

import Element as E exposing (..)
import Element.Events as Events exposing (onClick)
import Html.Attributes as HA
import UI.Action as Action
import UI.Background as Background
import UI.Icon as Icon
import UI.Spacing as UI


type Dialog msg
    = NoDialog
    | Modal (DialogType msg)


modal : DialogType msg -> Dialog msg
modal =
    Modal


none : Dialog msg
none =
    NoDialog


type DialogType msg
    = ConfirmationDialog { element : Element msg, onPositive : msg, onNegative : msg, onClose : msg }


confirmation : { content : Element msg, onPositive : msg, onNegative : msg, onClose : msg } -> DialogType msg
confirmation { content, onPositive, onNegative, onClose } =
    ConfirmationDialog
        { onPositive = onPositive
        , onNegative = onNegative
        , onClose = onClose
        , element =
            column
                [ centerX
                , centerY
                , UI.padding 1
                , Background.solidWhite
                ]
                [ content
                , row
                    [ UI.paddingEach { top = 1, bottom = -10, right = -10, left = -10 }
                    , UI.spacing -5
                    , centerX
                    ]
                    [ Action.toElement <| Action.large <| Action.clickable { text = "Yes", icon = Icon.none, onClick = onPositive }
                    , Action.toElement <| Action.large <| Action.clickable { text = "No", icon = Icon.none, onClick = onNegative }
                    ]
                ]
        }


toElement : Dialog msg -> Element msg
toElement dialog =
    case dialog of
        NoDialog ->
            E.none

        Modal (ConfirmationDialog { element, onPositive, onNegative, onClose }) ->
            el
                [ width fill
                , height fill
                , Background.transparentHeavyBlack
                , onClick onClose
                ]
                element
