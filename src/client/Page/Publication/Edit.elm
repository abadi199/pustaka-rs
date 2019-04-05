module Page.Publication.Edit exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Browser
import Browser.Navigation as Nav
import Css exposing (..)
import Entity.Category exposing (Category)
import Entity.Image as Image exposing (Image)
import Entity.Publication as Publication
import Entity.Thumbnail as Thumbnail exposing (Thumbnail(..))
import File exposing (File)
import File.Select as Select
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import Html.Styled.Events as HE
import Json.Decode as JD
import ReloadableData exposing (ReloadableWebData)
import Route
import UI.Action as Action
import UI.Card as Card
import UI.Heading as UI exposing (Level(..))
import UI.Icon as Icon
import UI.Layout
import UI.Nav.Side
import UI.Parts.BreadCrumb as UI
import UI.Parts.Dialog as Dialog exposing (Dialog)
import UI.Parts.Form as Form
import UI.Parts.Search
import UI.Poster as UI
import UI.ReloadableData
import UI.Spacing as UI



-- MODEL


type alias Model =
    { searchText : String
    , publication : ReloadableWebData Int Publication.MetaData
    , thumbnailHover : Bool
    , deleteConfirmation : Dialog Msg
    , cover : ReloadableWebData () Image
    }


init : Int -> ( Model, Cmd Msg )
init publicationId =
    ( { searchText = ""
      , publication = ReloadableData.Loading publicationId
      , thumbnailHover = False
      , deleteConfirmation = Dialog.none
      , cover = ReloadableData.NotAsked ()
      }
    , Publication.get { publicationId = publicationId, msg = GetPublicationCompleted }
    )



-- MESSAGE


type Msg
    = NoOp
    | LinkClicked String
    | GetPublicationCompleted (ReloadableWebData Int Publication.MetaData)
    | PublicationChanged Field
    | FormSubmitted
    | SubmissionCompleted (ReloadableWebData Int ())
    | BrowseClicked
    | FileSelected File
    | FilesDropped File (List File)
    | ThumbnailUploaded (ReloadableWebData () ())
    | ThumbnailDeleted (ReloadableWebData () ())
    | DragEnter
    | DragLeave
    | DeleteClicked
    | DeleteConfirmed
    | DeleteCancelled
    | CoverDownloaded (ReloadableWebData () Image)


type Field
    = TitleField String
    | ISBNField String



-- VIEW


view : String -> ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view logoUrl categories model =
    UI.Layout.withSideNav
        { title = "Pustaka - Edit Publication"
        , logoUrl = logoUrl
        , sideNav =
            categories
                |> UI.Nav.Side.view LinkClicked UI.Nav.Side.NoSelection
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp) model.searchText)
        , content =
            UI.ReloadableData.view
                (\publication ->
                    viewEdit
                        { publication = publication
                        , isHover = model.thumbnailHover
                        , cover = model.cover
                        }
                )
                model.publication
        , dialog = model.deleteConfirmation
        }


viewEdit :
    { isHover : Bool
    , publication : Publication.MetaData
    , cover : ReloadableWebData () Image
    }
    -> Html Msg
viewEdit { isHover, publication, cover } =
    div [ css [ UI.spacing 1, width (pct 100) ] ]
        [ UI.breadCrumb []
        , div [ css [ width (pct 100), UI.spacing 1 ] ]
            [ viewPoster { isHover = isHover, publication = publication, cover = cover }
            , div [ css [ width (pct 100), UI.spacing 1 ] ]
                [ UI.heading One "Edit Publication"
                , Form.form
                    { fields =
                        [ Form.field
                            { label = "Title"
                            , value = publication.title
                            , onChange = TitleField >> PublicationChanged
                            }
                        , Form.field
                            { label = "ISBN"
                            , value = publication.isbn
                            , onChange = ISBNField >> PublicationChanged
                            }
                        ]
                    , onSubmit = FormSubmitted
                    }
                ]
            ]
        ]


viewPoster :
    { isHover : Bool
    , publication : Publication.MetaData
    , cover : ReloadableWebData () Image
    }
    -> Html Msg
viewPoster { isHover, publication, cover } =
    Card.bordered [ css [] ]
        (case publication.thumbnail of
            NoThumbnail ->
                { actions = []
                , content = [ dropZone isHover ]
                }

            Thumbnail ->
                { actions =
                    [ Action.compact <|
                        Action.clickable
                            { text = "Delete Poster"
                            , icon = Icon.delete Icon.large
                            , onClick = DeleteClicked
                            }
                    ]
                , content =
                    [ div [] [ UI.reloadablePoster { title = publication.title, image = cover } ] ]
                }

            New _ ->
                { actions = []
                , content = [ dropZone isHover ]
                }
        )


dropZone : Bool -> Html Msg
dropZone isHover =
    let
        { width, height } =
            UI.posterDimension
    in
    div
        [ css
            [ backgroundColor (rgba 0 0 0 0.25)
            , borderColor (rgba 223 52 92 1)
            , borderStyle dashed
            , if isHover then
                borderWidth (px 5)

              else
                borderWidth (px 0)
            , Css.width (px <| toFloat width)
            , Css.height (px <| toFloat height)
            , cursor pointer
            ]
        , hijackOn "drop" dropDecoder
        , hijackOn "dragenter" (JD.succeed DragEnter)
        , hijackOn "dragover" (JD.succeed DragEnter)
        , hijackOn "dragleave" (JD.succeed DragLeave)
        , HE.onClick BrowseClicked
        ]
        [ div [ css [ UI.spacing -10 ] ]
            [ div [] [ text "Drop file here" ]
            , div [] [ text "or" ]
            , div [] [ text "click to browse" ]
            ]
        ]


hijackOn : String -> JD.Decoder msg -> Attribute msg
hijackOn event decoder =
    HE.preventDefaultOn event (JD.map hijack decoder)


hijack : msg -> ( msg, Bool )
hijack msg =
    ( msg, True )


dropDecoder : JD.Decoder Msg
dropDecoder =
    JD.at [ "dataTransfer", "files" ] (JD.oneOrMore FilesDropped File.decoder)



-- UPDATE


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked url ->
            ( model, Nav.pushUrl key url )

        GetPublicationCompleted reloadableData ->
            ( { model | publication = reloadableData }
            , reloadableData
                |> ReloadableData.toSuccess
                |> Maybe.map
                    (\publication ->
                        if Thumbnail.hasThumbnail publication.thumbnail then
                            Publication.downloadCover
                                { publicationId = publication.id
                                , msg = CoverDownloaded
                                }

                        else
                            Cmd.none
                    )
                |> Maybe.withDefault Cmd.none
            )

        PublicationChanged value ->
            ( { model | publication = model.publication |> ReloadableData.map (updatePublication value) }
            , Cmd.none
            )

        FormSubmitted ->
            ( { model
                | publication =
                    model.publication
                        |> ReloadableData.loading
              }
            , model.publication
                |> ReloadableData.toMaybe
                |> Maybe.map
                    (\publication ->
                        Publication.update
                            { publication = publication
                            , msg = SubmissionCompleted
                            }
                    )
                |> Maybe.withDefault Cmd.none
            )

        SubmissionCompleted reloadableData ->
            reloadableData
                |> ReloadableData.toError
                |> Maybe.map
                    (\err ->
                        ( { model | publication = ReloadableData.setError err model.publication }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault ( model, navigateToPublication key model.publication )

        BrowseClicked ->
            ( model, Select.file [] FileSelected )

        FileSelected file ->
            uploadFile file model

        ThumbnailUploaded data ->
            case data |> ReloadableData.toResult of
                Ok _ ->
                    ( { model
                        | publication =
                            model.publication
                                |> ReloadableData.map Publication.addThumbnail
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        ThumbnailDeleted data ->
            case data |> ReloadableData.toResult of
                Ok _ ->
                    ( { model
                        | publication =
                            model.publication
                                |> ReloadableData.map Publication.removeThumbnail
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        FilesDropped file _ ->
            uploadFile file model

        DragEnter ->
            ( { model | thumbnailHover = True }, Cmd.none )

        DragLeave ->
            ( { model | thumbnailHover = False }, Cmd.none )

        DeleteClicked ->
            ( { model
                | deleteConfirmation =
                    Dialog.modal <|
                        Dialog.confirmation
                            { content = text "Are you sure you want to delete the cover image?"
                            , onPositive = DeleteConfirmed
                            , onNegative = DeleteCancelled
                            , onClose = DeleteCancelled
                            }
              }
            , Cmd.none
            )

        DeleteConfirmed ->
            ( { model | deleteConfirmation = Dialog.none }
            , model.publication
                |> ReloadableData.toMaybe
                |> Maybe.map
                    (\publication ->
                        Publication.deleteThumbnail
                            { publicationId = publication.id
                            , msg = ThumbnailDeleted
                            }
                    )
                |> Maybe.withDefault Cmd.none
            )

        DeleteCancelled ->
            ( { model | deleteConfirmation = Dialog.none }, Cmd.none )

        CoverDownloaded data ->
            ( { model | cover = data }, Cmd.none )


refreshThumbnail model _ =
    ( model, Cmd.none )


uploadFile : File -> Model -> ( Model, Cmd Msg )
uploadFile file model =
    ( { model | thumbnailHover = False }
    , model.publication
        |> ReloadableData.toMaybe
        |> Maybe.map
            (\publication ->
                Publication.uploadThumbnail
                    { publicationId = publication.id
                    , fileName = "thumbnail"
                    , file = file
                    , msg = ThumbnailUploaded
                    }
            )
        |> Maybe.withDefault Cmd.none
    )


navigateToPublication : Nav.Key -> ReloadableWebData Int Publication.MetaData -> Cmd Msg
navigateToPublication key reloadableData =
    reloadableData
        |> ReloadableData.toMaybe
        |> Maybe.map (\publication -> Nav.pushUrl key (Route.publicationUrl publication.id))
        |> Maybe.withDefault Cmd.none


updatePublication : Field -> Publication.MetaData -> Publication.MetaData
updatePublication field publication =
    case field of
        TitleField value ->
            { publication | title = value }

        ISBNField value ->
            { publication | isbn = value }
