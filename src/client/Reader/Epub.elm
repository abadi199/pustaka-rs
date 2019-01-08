module Reader.Epub exposing (reader)

import Css exposing (..)
import Entity.Publication as Publication
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Reader exposing (PageView(..))


reader : Publication.Data -> PageView -> Html msg
reader pub pageView =
    let
        _ =
            Debug.log "data" pub
    in
    node "epub-viewer" [ attribute "epub" "sample.epub" ] []
