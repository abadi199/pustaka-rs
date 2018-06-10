module Msg exposing (Msg(..))

import Entity.Category exposing (Category)
import ReloadableData exposing (ReloadableWebData)


type Msg
    = NoOp
    | GetCategoriesCompleted (ReloadableWebData (List Category))
