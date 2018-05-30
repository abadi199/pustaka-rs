module Model exposing (Model, initialModel)

import UI.Input.Text


type alias Model =
    { firstName : UI.Input.Text.State
    , lastName : UI.Input.Text.State
    }


initialModel : Model
initialModel =
    { firstName = UI.Input.Text.initialState
    , lastName = UI.Input.Text.initialState
    }
