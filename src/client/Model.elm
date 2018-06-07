module Model exposing (Model, initialModel)

import Entity.Category exposing (Category)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)


type alias Model =
    { categories : ReloadableWebData (List Category) }


initialModel : Model
initialModel =
    { categories = Loading
    }
