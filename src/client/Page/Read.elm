module Page.Read
    exposing
        ( Model
        , Msg
        , init
        , initialModel
        , update
        , view
        )

import Browser
import Entity.Publication as Publication
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Task
import UI.ReloadableData


type alias Model =
    { publication : ReloadableWebData Int Publication.Data }


type Msg
    = GetDataCompleted (ReloadableWebData Int Publication.Data)


init : Int -> ( Model, Cmd Msg )
init pubId =
    ( initialModel pubId, Publication.read pubId |> Task.perform GetDataCompleted )


initialModel : Int -> Model
initialModel pubId =
    { publication = Loading pubId }


view : Model -> Browser.Document Msg
view model =
    { title = "Read"
    , body =
        UI.ReloadableData.view
            (\pub ->
                div []
                    [ header pub
                    , pages pub
                    , footer pub
                    ]
            )
            model.publication
            |> List.map Html.Styled.toUnstyled
    }


header : Publication.Data -> Html Msg
header pub =
    div [] [ text pub.title ]


pages : Publication.Data -> Html Msg
pages pub =
    div []
        [ img [ src <| "/api/publication/read/" ++ String.fromInt pub.id ++ "/page/1" ] []
        , img [ src <| "/api/publication/read/" ++ String.fromInt pub.id ++ "/page/2" ] []
        ]


footer : Publication.Data -> Html Msg
footer pub =
    div [] []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetDataCompleted data ->
            ( { model | publication = data }, Cmd.none )
