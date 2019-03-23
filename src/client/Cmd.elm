module Cmd exposing (alsoDo, andThen)


alsoDo : (model -> Cmd msg) -> ( model, Cmd msg ) -> ( model, Cmd msg )
alsoDo additionalCmdF ( model, cmd ) =
    ( model, Cmd.batch [ cmd, additionalCmdF model ] )


andThen : (model -> ( model, Cmd msg )) -> ( model, Cmd msg ) -> ( model, Cmd msg )
andThen f ( model, cmd ) =
    let
        ( nextModel, nextCmd ) =
            f model
    in
    ( nextModel, Cmd.batch [ nextCmd, cmd ] )
