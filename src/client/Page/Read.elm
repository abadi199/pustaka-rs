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
    | Comic Publication.Data Comic.Model


toEpub : PublicationType -> Maybe ( Publication.Data, Epub.Model )
toEpub publicationType =
    case publicationType of
        Epub publication model ->
            Just ( publication, model )

        _ ->
            Nothing


toComic : PublicationType -> Maybe ( Publication.Data, Comic.Model )
toComic publicationType =
    case publicationType of
        Comic publication model ->
            Just ( publication, model )

        _ ->
            Nothing



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

            Just (Comic publication comicModel) ->
                Comic.subscription comicModel |> Sub.map ComicMsg

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
    | ComicMsg Comic.Msg



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
                    Comic publication comicModel ->
                        layout ComicMsg
                            { header =
                                Comic.header
                                    { backUrl = model.backUrl }
                                    publication
                                    comicModel
                            , slider = Comic.slider comicModel
                            , reader = Comic.reader publication comicModel
                            , previous = Comic.previous
                            , next = Comic.next
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
                            , previous = Epub.previous
                            , next = Epub.next
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
        , height fill
        ]
        [ previous |> E.map tagger
        , E.el
            [ centerX
            , UI.Events.onMouseMove MouseMoved
            , width fill
            , height fill
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
            model.publication
                |> ReloadableData.toMaybe
                |> Maybe.andThen toEpub
                |> Maybe.map (updateEpub key epubMsg model)
                |> Maybe.withDefault
                    ( model, Cmd.none )

        ComicMsg comicMsg ->
            model.publication
                |> ReloadableData.toMaybe
                |> Maybe.andThen toComic
                |> Maybe.map (updateComic key comicMsg model)
                |> Maybe.withDefault ( model, Cmd.none )


updateEpub : Nav.Key -> Epub.Msg -> Model -> ( Publication.Data, Epub.Model ) -> ( Model, Cmd Msg )
updateEpub key epubMsg model ( publication, epubModel ) =
    let
        ( updatedEpubModel, epubCmd ) =
            Epub.update key epubMsg { model = epubModel, publication = publication }
    in
    ( { model | publication = model.publication |> ReloadableData.map (always (Epub publication updatedEpubModel)) }
    , epubCmd |> Cmd.map EpubMsg
    )


updateComic : Nav.Key -> Comic.Msg -> Model -> ( Publication.Data, Comic.Model ) -> ( Model, Cmd Msg )
updateComic key comicMsg model ( publication, comicModel ) =
    let
        ( updatedComicModel, comicCmd ) =
            Comic.update key comicMsg comicModel publication
    in
    ( { model
        | publication =
            model.publication
                |> ReloadableData.map (always (Comic publication updatedComicModel))
      }
    , comicCmd |> Cmd.map ComicMsg
    )


updateCompletedData : ReloadableWebData Int Publication.Data -> Model -> ( Model, Cmd Msg )
updateCompletedData data model =
    let
        publicationId =
            ReloadableData.toInitial data

        mediaFormat =
            data
                |> ReloadableData.toMaybe
                |> Maybe.map (\pub -> pub.mediaFormat)

        ( publicationType, cmd ) =
            case mediaFormat of
                Just MediaFormat.CBR ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.map (\publication -> Comic.init publication |> Tuple.mapFirst (Comic publication))
                        |> extract
                        |> Tuple.mapSecond (Maybe.withDefault Cmd.none >> Cmd.map ComicMsg)

                Just MediaFormat.CBZ ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.map (\publication -> Comic.init publication |> Tuple.mapFirst (Comic publication))
                        |> extract
                        |> Tuple.mapSecond (Maybe.withDefault Cmd.none >> Cmd.map ComicMsg)

                Just MediaFormat.Epub ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.andThen (\publication -> Success publicationId (Epub publication Epub.initialModel))
                        |> (\a -> ( a, Cmd.none ))

                Just MediaFormat.NoMediaFormat ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.andThen (\publication -> Failure (SimpleError "Unknown media format") publicationId)
                        |> (\a -> ( a, Cmd.none ))

                Nothing ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.andThen (\publication -> Failure (SimpleError "Unknown media format") publicationId)
                        |> (\a -> ( a, Cmd.none ))
    in
    ( { model | publication = publicationType }
    , cmd
    )


extract : ReloadableData e i ( a, b ) -> ( ReloadableData e i a, Maybe b )
extract data =
    ( data |> ReloadableData.map (\( a, b ) -> a)
    , data |> ReloadableData.toMaybe |> Maybe.map (\( a, b ) -> b)
    )
