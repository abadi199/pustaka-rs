module Msg exposing (Msg(..))

import Entity.Category exposing (Category)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | GetCategoriesCompleted (WebData (List Category))
