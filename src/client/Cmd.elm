module Cmd exposing (alsoDo)


alsoDo : (model -> Cmd msg) -> ( model, Cmd msg ) -> ( model, Cmd msg )
alsoDo additionalCmdF ( model, cmd ) =
    ( model, Cmd.batch [ cmd, additionalCmdF model ] )
