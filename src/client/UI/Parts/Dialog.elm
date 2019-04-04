module UI.Parts.Dialog exposing
    ( Dialog
    , DialogType
    , confirmation
    , modal
    , none
    , toElement
    )

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events as HE exposing (onClick)
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
    = ConfirmationDialog { element : Html msg, onPositive : msg, onNegative : msg, onClose : msg }


confirmation : { content : Html msg, onPositive : msg, onNegative : msg, onClose : msg } -> DialogType msg
confirmation { content, onPositive, onNegative, onClose } =
    ConfirmationDialog
        { onPositive = onPositive
        , onNegative = onNegative
        , onClose = onClose
        , element =
            div
                [ css
                    [ displayFlex
                    , alignItems center
                    , justifyContent center
                    , UI.padding 1
                    , Background.solidWhite
                    ]
                ]
                [ content
                , div
                    [ css
                        [ UI.paddingEach { top = 1, bottom = -10, right = -10, left = -10 }
                        , UI.spacing -5
                        , displayFlex
                        , justifyContent center
                        ]
                    ]
                    [ Action.toHtml <| Action.large <| Action.clickable { text = "Yes", icon = Icon.none, onClick = onPositive }
                    , Action.toHtml <| Action.large <| Action.clickable { text = "No", icon = Icon.none, onClick = onNegative }
                    ]
                ]
        }


toElement : Dialog msg -> Html msg
toElement dialog =
    case dialog of
        NoDialog ->
            text ""

        Modal (ConfirmationDialog { element, onPositive, onNegative, onClose }) ->
            div
                [ css
                    [ width (pct 100)
                    , height (pct 100)
                    , Background.transparentHeavyBlack
                    ]
                , onClick onClose
                ]
                [ element ]
