module Msg exposing (Msg(..))

import UI.Input.Text


type Msg
    = NoOp
    | FirstNameUpdated UI.Input.Text.State
    | LastNameUpdated UI.Input.Text.State
