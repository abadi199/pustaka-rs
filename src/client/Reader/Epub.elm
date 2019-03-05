module Reader.Epub exposing (reader)

import Browser.Dom exposing (Viewport)
import Css exposing (..)
import Element as E exposing (..)
import Entity.Publication as Publication
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Json.Encode as JE
import Reader exposing (PageView(..))
import UI.Events


reader :
    { viewport : Viewport
    , publication : Publication.Data
    , progress : Publication.Progress
    , onPageChanged : Float -> msg
    , onMouseMove : msg
    , onReady : msg
    , pageView : PageView
    }
    -> Element msg
reader { pageView, onPageChanged, onReady, viewport, publication, progress, onMouseMove } =
    E.html <|
        H.node "epub-viewer"
            [ publication.id
                |> String.fromInt
                |> (\id ->
                        "/api/publication/download/"
                            ++ id
                            ++ "/epub"
                   )
                |> HA.attribute "epub"
            , HA.attribute "width" (viewport.viewport.width - 200 |> String.fromFloat)
            , HA.attribute "height" (viewport.viewport.height |> String.fromFloat)
            , HA.attribute "page" (Reader.getPageNumber pageView |> String.fromInt)
            , HA.attribute "percentage" (progress |> Publication.toPercentage |> String.fromFloat)
            , HE.on "pageChanged" (JD.at [ "detail" ] JD.float |> JD.map onPageChanged)
            , HE.on "ready" (JD.succeed onReady)
            , UI.Events.onHtmlMouseMove onMouseMove
            ]
            []
