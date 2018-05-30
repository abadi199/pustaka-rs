module UI.Input.Text
    exposing
        ( Config
        , State
        , initialState
        , value
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Murmur3
import Result
import UI.Input.Text.Internal as Internal
import UI.Validator as Validator


seed : Int
seed =
    95858


type alias State =
    Internal.State


initialState : State
initialState =
    Internal.initialState



-- CONFIG


type alias Config msg =
    Internal.Config msg -> Internal.Config msg


emptyConfig : Internal.Config msg
emptyConfig =
    Internal.Config
        { onUpdate = Nothing
        , labelText = Nothing
        , validators = Nothing
        }



-- GETTER


value : State -> Result (List String) String
value (Internal.State state) =
    Result.Ok state.value



-- VIEW


view : List (Config msg) -> State -> Html msg
view configurations (Internal.State state) =
    let
        domId =
            generateDomId internalConfig

        ((Internal.Config config) as internalConfig) =
            configure configurations
    in
    div []
        [ config.labelText
            |> Maybe.map (\labelText -> Html.label [ for domId ] [ Html.text labelText ])
            |> Maybe.withDefault (Html.text "")
        , input
            [ config.onUpdate
                |> Maybe.map (\onUpdate -> onInput (\value -> onUpdate (Internal.State { state | value = value, shouldValidate = True })))
                |> Maybe.withDefault (id domId)
            , id domId
            , Html.Attributes.value state.value
            ]
            []
        , if state.shouldValidate then
            config.validators
                |> Maybe.map (\validators -> Validator.view validators state.value)
                |> Maybe.withDefault (Html.text "")
          else
            Html.text ""
        ]


configure : List (Config msg) -> Internal.Config msg
configure configurations =
    configurations
        |> List.foldl (\f config -> f config) emptyConfig


generateDomId : Internal.Config config -> String
generateDomId (Internal.Config config) =
    toString <|
        Murmur3.hashString seed (toString config)
