module UI.Parts.Form exposing (Field, field, form)

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events as HE
import UI.Action as Action
import UI.Css.Grid as Grid
import UI.Icon as Icon
import UI.Spacing as UI


type Field msg
    = Field (FieldData msg)


type alias FieldData msg =
    { id : String, label : String, value : String, onChange : String -> msg }


field : { id : String, label : String, value : String, onChange : String -> msg } -> Field msg
field =
    Field


form : { fields : List (Field msg), onSubmit : msg } -> Html msg
form { fields, onSubmit } =
    H.form [ HE.onSubmit onSubmit ]
        [ div
            [ css
                [ width (pct 100)
                , UI.paddingBottom UI.Large
                , Grid.display
                , Grid.rowGap 20
                ]
            ]
            (fields
                |> List.map viewField
            )
        , viewActions { onSubmit = onSubmit }
        ]


viewField : Field msg -> Html msg
viewField (Field { id, label, value, onChange }) =
    H.label
        [ css
            [ width (pct 100)
            , displayFlex
            , flexDirection column
            ]
        ]
        [ text label
        , input [ HA.type_ "text", HE.onInput onChange, HA.value value ]
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
            [ Grid.display
            , Grid.templateColumns [ "auto" ]
            , UI.paddingTop UI.Large
            , borderTop3 (px 1) solid (rgba 0 0 0 0.25)
            , justifyContent flexEnd
            ]
        ]
        (actions |> List.map Action.toHtml)
