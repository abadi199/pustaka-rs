module Api exposing (getCategories)

import Entity.Category
import Json.Decode as JD
import Msg exposing (..)
import RemoteData.Http


getCategories : Cmd Msg
getCategories =
    RemoteData.Http.get "/api/category"
        GetCategoriesCompleted
        (JD.list Entity.Category.decoder)
