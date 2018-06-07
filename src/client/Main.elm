module Main exposing (main)

import Api
import Html exposing (..)
import Model exposing (Model)
import Msg exposing (Msg)
import Update exposing (update)
import View exposing (view)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : ( Model, Cmd Msg )
init =
    ( Model.initialModel, Api.getCategories )
