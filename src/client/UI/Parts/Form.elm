module UI.Parts.Form exposing (Field, field, form)

import Html.Styled as H
import Html.Styled.Events as HA
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


form : { fields : List (Field msg), onSubmit : msg } -> Element msg
form { fields, onSubmit } =
    el [ width fill ]
        (html <|
            H.form [ HA.onSubmit onSubmit ]
                [ layoutWith { options = [ noStaticStyleSheet ] } [] <|
                    column [ width fill, UI.spacing 1 ]
                        [ column [ width fill, UI.spacing -5 ]
                            (fields
                                |> List.map viewField
                            )
                        , viewActions { onSubmit = onSubmit }
                        ]
                ]
        )


viewField : Field msg -> Element msg
viewField (Field { label, value, onChange }) =
    row [ width fill ]
        [ EI.text []
            { onChange = onChange
            , label = EI.labelAbove [] (text label)
            , text = value
            , placeholder = Nothing
            }
        ]


viewActions : { onSubmit : msg } -> Element msg
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
    row
        [ alignRight
        , alignBottom
        ]
        (actions |> List.map Action.toElement)
