module UI.Input.Text.Internal
    exposing
        ( Config(..)
        , State(..)
        , initialState
        )

import UI.Validator as Validator exposing (Validator)


type State
    = State
        { value : String
        , shouldValidate : Bool
        }


initialState : State
initialState =
    State
        { value = ""
        , shouldValidate = False
        }


type Config msg
    = Config
        { labelText : Maybe String
        , onUpdate : Maybe (State -> msg)
        , validators : Maybe (List (Validator String))
        }
