module Page.Read exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Browser
import Browser.Dom exposing (Viewport)
import Browser.Events
import Browser.Navigation as Nav
import Element as E exposing (..)
import Element.Border as Border exposing (shadow)
import Element.Events as Events exposing (onClick)
import Element.Font as Font
import Entity.MediaFormat as MediaFormat exposing (MediaFormat)
import Entity.Publication as Publication
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Http
import Json.Decode as JD
import Keyboard
import Reader exposing (PageView(..))
import Reader.Comic as Comic
import Reader.Epub as Epub
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Task
import UI.Action as Action
import UI.Background as Background
import UI.Error
import UI.Events
import UI.Icon as Icon
import UI.Link as UI
import UI.Parts.Header as Header
import UI.Parts.Slider as Slider
import UI.ReloadableData
import UI.Spacing as UI



-- MODEL


type alias Model =
    { publication : ReloadableData ReadError Int PublicationType
    , backUrl : String
    , delta : Float
    }


type ReadError
    = HttpError Http.Error
    | SimpleError String


type PublicationType
    = Epub Publication.Data Epub.Model
    | Comic Publication.Data


overlayVisibilityDuration : Float
overlayVisibilityDuration =
    2000



-- INIT


init : Int -> Maybe String -> ( Model, Cmd Msg )
init publicationId previousUrl =
    ( { publication = Loading publicationId
      , backUrl = previousUrl |> Maybe.withDefault (Route.publicationUrl publicationId)
      , delta = 0
      }
    , Cmd.batch
        [ Publication.read { publicationId = publicationId, msg = GetDataCompleted } ]
    )



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ case model.publication |> ReloadableData.toMaybe of
            Just (Epub publication epubModel) ->
                Epub.subscription epubModel |> Sub.map EpubMsg

            Just (Comic publication) ->
                Sub.none

            Nothing ->
                Sub.none
        , Keyboard.onEscape (LinkClicked model.backUrl)
        ]



-- MESSAGE


type Msg
    = NoOp
    | GetDataCompleted (ReloadableWebData Int Publication.Data)
    | LinkClicked String
    | MouseMoved
    | EpubMsg Epub.Msg



-- VIEW


view : Viewport -> Model -> Browser.Document Msg
view viewport model =
    { title = "Read"
    , body =
        UI.ReloadableData.custom
            (\error ->
                case error of
                    SimpleError string ->
                        UI.Error.string string

                    HttpError httpError ->
                        UI.Error.http httpError
            )
            (\publicationType ->
                case publicationType of
                    Comic publication ->
                        layout identity
                            { header = text "Header"
                            , slider = text "Slider"
                            , reader = text "Content"
                            , previous = text "Left"
                            , next = text "Right"
                            }

                    Epub publication epubModel ->
                        layout EpubMsg
                            { header =
                                Epub.header
                                    { backUrl = model.backUrl
                                    , publication = publication
                                    , model = epubModel
                                    }
                            , slider = Epub.slider epubModel
                            , reader =
                                Epub.reader
                                    { viewport = viewport
                                    , publication = publication
                                    , model = epubModel
                                    }
                            , previous = Epub.previous publication
                            , next = Epub.next publication
                            }
            )
            model.publication
            |> E.layout []
            |> List.singleton
    }


layout :
    (msg -> Msg)
    ->
        { previous : Element msg
        , next : Element msg
        , header : Element msg
        , slider : Element msg
        , reader : Element msg
        }
    -> Element Msg
layout tagger { header, slider, reader, previous, next } =
    row
        [ inFront <| E.map tagger <| header
        , inFront <| E.map tagger <| slider
        , width fill
        ]
        [ previous |> E.map tagger
        , E.el
            [ centerX
            , UI.Events.onMouseMove MouseMoved
            ]
            (reader |> E.map tagger)
        , next |> E.map tagger
        ]



-- UPDATE


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetDataCompleted data ->
            updateCompletedData data model

        LinkClicked url ->
            ( model, Nav.pushUrl key url )

        MouseMoved ->
            ( model, Cmd.none )

        EpubMsg epubMsg ->
            case model.publication |> ReloadableData.toMaybe of
                Just (Epub publication epubModel) ->
                    let
                        ( updatedEpubModel, epubCmd ) =
                            Epub.update key epubMsg { model = epubModel, publication = publication }
                    in
                    ( { model | publication = model.publication |> ReloadableData.map (always (Epub publication updatedEpubModel)) }
                    , epubCmd |> Cmd.map EpubMsg
                    )

                _ ->
                    ( model, Cmd.none )


updateCompletedData : ReloadableWebData Int Publication.Data -> Model -> ( Model, Cmd Msg )
updateCompletedData data model =
    let
        publicationId =
            ReloadableData.toInitial data

        mediaFormat =
            data
                |> ReloadableData.toMaybe
                |> Maybe.map (\pub -> pub.mediaFormat)

        publicationType : ReloadableData ReadError Int PublicationType
        publicationType =
            case mediaFormat of
                Just MediaFormat.CBR ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.andThen (\publication -> Success publicationId (Comic publication))

                Just MediaFormat.CBZ ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.andThen (\publication -> Success publicationId (Comic publication))

                Just MediaFormat.Epub ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.andThen (\publication -> Success publicationId (Epub publication Epub.initialModel))

                Just MediaFormat.NoMediaFormat ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.andThen (\publication -> Failure (SimpleError "Unknown media format") publicationId)

                Nothing ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.andThen (\publication -> Failure (SimpleError "Unknown media format") publicationId)
    in
    ( { model | publication = publicationType }
    , Cmd.none
    )
