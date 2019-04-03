module UI.Parts.Form exposing (Field, field, form)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events as HE
import UI.Action as Action
import UI.Icon as Icon
import UI.Spacing as UI


type Field msg
    = Field (FieldData msg)


type alias FieldData msg =
    { label : String, value : String, onChange : String -> msg }


field : { label : String, value : String, onChange : String -> msg } -> Field msg
field =
    Field


form : { fields : List (Field msg), onSubmit : msg } -> Html msg
form { fields, onSubmit } =
    H.form [ HE.onSubmit onSubmit ]
        [ div [ css [ width (pct 100), UI.spacing 1 ] ]
            [ div [ css [ width (pct 100), UI.spacing -5 ] ]
                (fields
                    |> List.map viewField
                )
            , viewActions { onSubmit = onSubmit }
            ]
        ]


viewField : Field msg -> Html msg
viewField (Field { label, value, onChange }) =
    H.label [ css [ width (pct 100) ] ]
        [ text label
        , input [ HA.type_ "text", HE.onInput onChange ]
            []
        ]


viewActions : { onSubmit : msg } -> Html msg
viewActions { onSubmit } =
    let
        actions =
            [ Action.large <|
                Action.clickable
                    { text = "Save"
                    , icon = Icon.save Icon.small
                    , onClick = onSubmit
                    }
            ]
    in
    div
        [ css
            [ displayFlex
            , flexDirection row
            , justifyContent flexStart
            , alignItems flexEnd
            ]
        ]
        (actions |> List.map Action.toHtml)
