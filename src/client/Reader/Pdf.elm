module Reader.Pdf exposing
    ( Model
    , Msg
    , header
    , init
    , next
    , previous
    , reader
    , slider
    , subscription
    , update
    )

import Browser.Dom exposing (Viewport)
import Browser.Events
import Browser.Navigation as Nav
import Css exposing (..)
import Entity.Progress as Progress exposing (Progress)
import Entity.Publication as Publication
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events as HE exposing (onClick)
import Json.Decode as JD
import Keyboard
import ReloadableData exposing (ReloadableWebData)
import UI.Events
import UI.Icon as Icon
import UI.Loading
import UI.Parts.Header as Header
import UI.Parts.Slider as Slider



-- MODEL


type alias Model =
    { initialProgress : Maybe Progress
    , progress : Maybe Progress
    , isReady : Bool
    , overlayVisibility : Header.Visibility
    , pageCounter : Int
    }


init : Publication.Data -> ( Model, Cmd Msg )
init publication =
    ( initialModel
    , Publication.getProgress { publicationId = publication.id, msg = GetProgressCompleted }
    )


initialModel : Model
initialModel =
    { initialProgress = Nothing
    , progress = Nothing
    , isReady = True
    , overlayVisibility = Header.visible counter
    , pageCounter = 0
    }


counter : { counter : Float }
counter =
    { counter = 2000 }


subscription : Model -> Sub Msg
subscription model =
    Sub.batch
        [ if model.overlayVisibility |> Header.isVisible then
            Browser.Events.onAnimationFrameDelta Tick

          else
            Sub.none
        , Keyboard.onLeft PreviousPage
        , Keyboard.onRight NextPage
        ]



-- MESSAGE


type Msg
    = NoOp
    | MouseMoved
    | MouseClicked
    | Ready
    | PageChanged Float
    | PreviousPage
    | NextPage
    | SliderClicked Float
    | LinkClicked String
    | Tick Float
    | GetProgressCompleted (ReloadableWebData Int Float)



-- VIEW


reader :
    { viewport : Viewport
    , publication : Publication.Data
    , model : Model
    }
    -> Html Msg
reader ({ viewport, publication, model } as args) =
    model.progress
        |> Maybe.map (pdfViewer args)
        |> Maybe.withDefault UI.Loading.view


pdfViewer : { viewport : Viewport, publication : Publication.Data, model : Model } -> Progress -> Html Msg
pdfViewer { viewport, publication, model } progress =
    H.node "pdf-viewer"
        ([ publication.id
            |> String.fromInt
            |> (\id ->
                    "/api/publication/download/"
                        ++ id
                        ++ "/epub"
               )
            |> HA.attribute "epub"
         , HA.attribute "width" (viewport.viewport.width |> String.fromFloat)
         , HA.attribute "height" (viewport.viewport.height |> String.fromFloat)
         , HA.attribute "page" (model.pageCounter |> String.fromInt)
         , HE.on "pageChanged" (JD.at [ "detail" ] JD.float |> JD.map PageChanged)
         , HE.on "ready" (JD.succeed Ready)
         , HE.on "click" (JD.succeed MouseClicked)
         ]
            ++ (case model.initialProgress of
                    Just initialProgress ->
                        [ HA.attribute "percentage" (initialProgress |> Progress.toFloat |> String.fromFloat) ]

                    Nothing ->
                        []
               )
        )
        []


header : { backUrl : String, publication : Publication.Data, model : Model } -> Html Msg
header { backUrl, publication, model } =
    Header.header
        { visibility = model.overlayVisibility
        , backUrl = backUrl
        , onMouseMove = MouseMoved
        , onLinkClicked = LinkClicked
        , title = publication.title
        }


slider : Model -> Html Msg
slider model =
    case ( model.progress, Header.isVisible model.overlayVisibility ) of
        ( Nothing, _ ) ->
            text ""

        ( Just progress, False ) ->
            Slider.compact
                { onMouseMove = MouseMoved
                , percentage = progress |> Progress.toFloat
                , onClick = SliderClicked
                }

        ( Just progress, True ) ->
            Slider.large
                { onMouseMove = MouseMoved
                , percentage = progress |> Progress.toFloat
                , onClick = SliderClicked
                }


previous : Html Msg
previous =
    div
        [ onClick PreviousPage
        , css
            [ displayFlex
            , height (pct 100)
            , cursor pointer
            , justifyContent center
            , alignItems center
            , hover
                [ backgroundColor (rgba 0 0 0 0.025)
                ]
            ]
        ]
        [ Icon.previous Icon.large ]


next : Html Msg
next =
    div
        [ onClick NextPage
        , css
            [ displayFlex
            , height (pct 100)
            , cursor pointer
            , justifyContent center
            , alignItems center
            , hover
                [ backgroundColor (rgba 0 0 0 0.025)
                ]
            ]
        ]
        [ Icon.next Icon.large ]


update : Nav.Key -> Msg -> { model : Model, publication : Publication.Data } -> ( Model, Cmd Msg )
update key msg { model, publication } =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MouseMoved ->
            ( { model | overlayVisibility = Header.visible counter }, Cmd.none )

        MouseClicked ->
            ( { model | overlayVisibility = Header.toggle counter model.overlayVisibility }
            , Cmd.none
            )

        Ready ->
            ( { model | isReady = True }
            , Cmd.none
            )

        GetProgressCompleted data ->
            data
                |> ReloadableData.toMaybe
                |> Maybe.map
                    (\float ->
                        ( { model
                            | initialProgress = Just <| Progress.percentage float
                            , progress = Just <| Progress.percentage float
                          }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        PageChanged float ->
            let
                progress =
                    Progress.percentage float
            in
            ( { model | initialProgress = Just progress, progress = Just progress }
            , if model.isReady then
                Publication.updateProgress
                    { publicationId = publication.id
                    , progress = progress
                    , msg = always NoOp
                    }

              else
                Cmd.none
            )

        PreviousPage ->
            case model.progress of
                Nothing ->
                    ( model, Cmd.none )

                Just progress ->
                    if Progress.toFloat progress <= 0 then
                        ( model, Cmd.none )

                    else
                        ( { model | pageCounter = model.pageCounter - 1, initialProgress = Nothing }
                        , Cmd.none
                        )

        NextPage ->
            case model.progress of
                Nothing ->
                    ( model, Cmd.none )

                Just progress ->
                    if Progress.toFloat progress >= 100 then
                        ( model, Cmd.none )

                    else
                        ( { model | pageCounter = model.pageCounter + 1, initialProgress = Nothing }
                        , Cmd.none
                        )

        SliderClicked float ->
            ( { model
                | progress = Just <| Progress.percentage float
                , initialProgress = Just <| Progress.percentage float
              }
            , Cmd.none
            )

        LinkClicked string ->
            ( model, Nav.pushUrl key string )

        Tick delta ->
            model.overlayVisibility
                |> Header.toCounter
                |> Maybe.map (\currentCounter -> currentCounter - delta)
                |> Maybe.map Header.visibilityFromCounter
                |> Maybe.map
                    (\visibility ->
                        ( { model | overlayVisibility = visibility }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )
