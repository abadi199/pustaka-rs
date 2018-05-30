module Update exposing (update)

import Model exposing (Model)
import Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FirstNameUpdated state ->
            ( { model | firstName = state }, Cmd.none )

        LastNameUpdated state ->
            ( { model | lastName = state }, Cmd.none )
