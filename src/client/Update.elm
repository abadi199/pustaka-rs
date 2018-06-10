module Update exposing (update)

import Model exposing (Model)
import Msg exposing (Msg(..))
import ReloadableData


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetCategoriesCompleted webData ->
            ( { model | categories = ReloadableData.refresh model.categories webData }, Cmd.none )
