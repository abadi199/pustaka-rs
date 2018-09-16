module Page.Read exposing
    ( Model
    , Msg
    , init
    , initialModel
    , update
    , view
    )

import Browser
import Css exposing (..)
import Entity.Publication as Publication
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Task
import UI.ReloadableData


type alias Model =
    { publication : ReloadableWebData Int Publication.Data
    , currentPage : PageView
    }


type PageView
    = DoublePage Int Int
    | SinglePage Int


type Msg
    = GetDataCompleted (ReloadableWebData Int Publication.Data)
    | NextPage
    | PreviousPage


init : Int -> ( Model, Cmd Msg )
init pubId =
    ( initialModel pubId, Publication.read pubId |> Task.perform GetDataCompleted )


initialModel : Int -> Model
initialModel pubId =
    { publication = Loading pubId
    , currentPage = DoublePage 1 2
    }


view : Model -> Browser.Document Msg
view model =
    { title = "Read"
    , body =
        UI.ReloadableData.view
            (\pub ->
                div
                    [ css
                        [ displayFlex
                        , flexDirection row
                        , flexWrap noWrap
                        , alignItems center
                        , Css.height (vh 100)
                        ]
                    ]
                    [ left pub
                    , pages pub model.currentPage
                    , right pub
                    ]
            )
            model.publication
            |> List.map Html.Styled.toUnstyled
    }


left : Publication.Data -> Html Msg
left pub =
    div
        [ css
            [ backgroundColor (rgba 0 0 0 0.95)
            , color (rgba 255 255 255 1)
            , flex (int 1)
            , Css.height (pct 100)
            ]
        , onClick PreviousPage
        ]
        [ text pub.title ]


pages : Publication.Data -> PageView -> Html Msg
pages pub currentPage =
    let
        imgStyle =
            batch [ Css.height (pct 100) ]
    in
    div
        [ css
            [ flex (int 1)
            , displayFlex
            , flexDirection row
            , Css.height (pct 100)
            ]
        ]
        (case currentPage of
            DoublePage a b ->
                [ img [ css [ imgStyle ], src <| "/api/publication/read/" ++ String.fromInt pub.id ++ "/page/" ++ String.fromInt a ] []
                , img [ css [ imgStyle ], src <| "/api/publication/read/" ++ String.fromInt pub.id ++ "/page/" ++ String.fromInt b ] []
                ]

            SinglePage a ->
                [ img [ css [ imgStyle ], src <| "/api/publication/read/" ++ String.fromInt pub.id ++ "/page/" ++ String.fromInt a ] [] ]
        )


right : Publication.Data -> Html Msg
right pub =
    div
        [ css
            [ backgroundColor (rgba 0 0 0 0.95)
            , flex (int 1)
            , Css.height (pct 100)
            ]
        , onClick NextPage
        ]
        []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetDataCompleted data ->
            ( { model | publication = data }, Cmd.none )

        PreviousPage ->
            ( { model | currentPage = previousPage model.currentPage }, Cmd.none )

        NextPage ->
            ( { model | currentPage = nextPage model.currentPage }, Cmd.none )


previousPage : PageView -> PageView
previousPage currentPage =
    case currentPage of
        DoublePage a b ->
            DoublePage (a - 2) (b - 2)

        SinglePage a ->
            SinglePage (a - 1)


nextPage : PageView -> PageView
nextPage currentPage =
    case currentPage of
        DoublePage a b ->
            DoublePage (a + 2) (b + 2)

        SinglePage a ->
            SinglePage (a + 1)
