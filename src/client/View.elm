module View exposing (view)

import Html exposing (..)
import Model exposing (Model)
import Msg exposing (Msg(..))
import UI.Input.Text as InputText
import UI.Input.Text.Configs as InputText
import UI.Validator.String as StringValidator


view : Model -> Html Msg
view model =
    div []
        [ InputText.view
            [ InputText.onUpdate FirstNameUpdated
            , InputText.label "First Name"
            , InputText.validators
                [ StringValidator.required "First Name is required."
                , StringValidator.minLength 5 "First Name must be longer than 5 characters."
                , StringValidator.maxLength 10 "First Name must be shorter than 10 characters."
                ]
            ]
            model.firstName
        , InputText.value model.firstName
            |> Result.map text
            |> Result.withDefault (text "")
        , InputText.view
            [ InputText.onUpdate LastNameUpdated
            , InputText.label "Last Name"
            , InputText.validators
                [ StringValidator.required "Last Name is required"
                ]
            ]
            model.lastName
        ]
