module Main exposing (main)

import Browser
import Entity.Category
import Html exposing (..)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Update exposing (update)
import View exposing (view)


main : Program () Model Msg
main =
    Browser.fullscreen
        { init = init
        , onNavigation = Nothing
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : Browser.Env () -> ( Model, Cmd Msg )
init value =
    ( Model.initialModel
    , Entity.Category.list GetCategoriesCompleted
    )
