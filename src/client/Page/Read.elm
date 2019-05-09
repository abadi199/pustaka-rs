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
import Browser.Navigation as Nav
import Css exposing (..)
import Css.Global as Global exposing (global)
import Entity.MediaFormat as MediaFormat
import Entity.Publication as Publication
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Http
import Keyboard
import Reader.Comic as Comic
import Reader.Epub as Epub
import Reader.Pdf as Pdf
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import UI.Error
import UI.Events
import UI.ReloadableData
import UI.Reset exposing (reset)



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
    | Pdf Publication.Data Pdf.Model


toEpub : PublicationType -> Maybe ( Publication.Data, Epub.Model )
toEpub publicationType =
    case publicationType of
        Epub publication model ->
            Just ( publication, model )

        _ ->
            Nothing


toPdf : PublicationType -> Maybe ( Publication.Data, Pdf.Model )
toPdf publicationType =
    case publicationType of
        Pdf publication model ->
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
            Just (Pdf _ pdfModel) ->
                Pdf.subscription pdfModel |> Sub.map PdfMsg

            Just (Epub _ epubModel) ->
                Epub.subscription epubModel |> Sub.map EpubMsg

            Just (Comic _ comicModel) ->
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
    | PdfMsg Pdf.Msg



-- VIEW


view : Viewport -> Model -> Browser.Document Msg
view viewport model =
    { title = "Read"
    , body =
        [ H.toUnstyled <| reset
        , H.toUnstyled <| global [ Global.body [ overflowY hidden ] ]
        , H.toUnstyled <|
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
                                , reader =
                                    Comic.reader
                                        { viewport = viewport
                                        , publication = publication
                                        , model = comicModel
                                        }
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

                        Pdf publication pdfModel ->
                            layout PdfMsg
                                { header =
                                    Pdf.header
                                        { backUrl = model.backUrl
                                        , publication = publication
                                        , model = pdfModel
                                        }
                                , slider = Pdf.slider pdfModel
                                , reader =
                                    Pdf.reader
                                        { viewport = viewport
                                        , publication = publication
                                        , model = pdfModel
                                        }
                                , previous = Pdf.previous
                                , next = Pdf.next
                                }
                )
                model.publication
        ]
    }


layout :
    (msg -> Msg)
    ->
        { previous : Html msg
        , next : Html msg
        , header : Html msg
        , slider : Html msg
        , reader : Html msg
        }
    -> Html Msg
layout tagger { header, slider, reader, previous, next } =
    div
        [ css
            [ width (pct 100)
            , height (vh 100)
            , position relative
            ]
        ]
        [ div
            [ css
                [ height (pct 100) ]
            , UI.Events.onMouseMove MouseMoved
            ]
            [ reader |> H.map tagger ]
        , div
            [ css
                [ position absolute
                , top (px 0)
                , left (px 0)
                , height (pct 100)
                ]
            ]
            [ H.map tagger <| previous ]
        , div
            [ css
                [ position absolute
                , width (pct 100)
                , bottom (px 0)
                , left (px 0)
                ]
            ]
            [ H.map tagger <| slider ]
        , div
            [ css
                [ position absolute
                , top (px 0)
                , right (px 0)
                , height (pct 100)
                ]
            ]
            [ next |> H.map tagger ]
        , div
            [ css
                [ position absolute
                , width (pct 100)
                , top (px 0)
                , left (px 0)
                ]
            ]
            [ H.map tagger <| header ]
        ]



-- UPDATE


update : Nav.Key -> Viewport -> Msg -> Model -> ( Model, Cmd Msg )
update key viewport msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetDataCompleted data ->
            updateCompletedData viewport data model

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

        PdfMsg pdfMsg ->
            model.publication
                |> ReloadableData.toMaybe
                |> Maybe.andThen toPdf
                |> Maybe.map (updatePdf key pdfMsg model)
                |> Maybe.withDefault
                    ( model, Cmd.none )

        ComicMsg comicMsg ->
            model.publication
                |> ReloadableData.toMaybe
                |> Maybe.andThen toComic
                |> Maybe.map (updateComic key viewport comicMsg model)
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


updatePdf : Nav.Key -> Pdf.Msg -> Model -> ( Publication.Data, Pdf.Model ) -> ( Model, Cmd Msg )
updatePdf key pdfMsg model ( publication, pdfModel ) =
    let
        ( updatedPdfModel, cmd ) =
            Pdf.update key pdfMsg { model = pdfModel, publication = publication }
    in
    ( { model | publication = model.publication |> ReloadableData.map (always (Pdf publication updatedPdfModel)) }
    , cmd |> Cmd.map PdfMsg
    )


updateComic : Nav.Key -> Viewport -> Comic.Msg -> Model -> ( Publication.Data, Comic.Model ) -> ( Model, Cmd Msg )
updateComic key viewport comicMsg model ( publication, comicModel ) =
    let
        ( updatedComicModel, comicCmd ) =
            Comic.update key viewport comicMsg comicModel publication
    in
    ( { model
        | publication =
            model.publication
                |> ReloadableData.map (always (Comic publication updatedComicModel))
      }
    , comicCmd |> Cmd.map ComicMsg
    )


updateCompletedData : Viewport -> ReloadableWebData Int Publication.Data -> Model -> ( Model, Cmd Msg )
updateCompletedData viewport data model =
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
                        |> ReloadableData.map (\publication -> Comic.init viewport publication |> Tuple.mapFirst (Comic publication))
                        |> extract
                        |> Tuple.mapSecond (Maybe.withDefault Cmd.none >> Cmd.map ComicMsg)

                Just MediaFormat.CBZ ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.map (\publication -> Comic.init viewport publication |> Tuple.mapFirst (Comic publication))
                        |> extract
                        |> Tuple.mapSecond (Maybe.withDefault Cmd.none >> Cmd.map ComicMsg)

                Just MediaFormat.Epub ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.map (\publication -> Epub.init publication |> Tuple.mapFirst (Epub publication))
                        |> extract
                        |> Tuple.mapSecond (Maybe.withDefault Cmd.none >> Cmd.map EpubMsg)

                Just MediaFormat.NoMediaFormat ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.andThen (\_ -> Failure (SimpleError "Unknown media format") publicationId)
                        |> (\a -> ( a, Cmd.none ))

                Nothing ->
                    data
                        |> ReloadableData.mapErr HttpError
                        |> ReloadableData.andThen (\_ -> Failure (SimpleError "Unknown media format") publicationId)
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
