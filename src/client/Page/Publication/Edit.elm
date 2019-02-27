module Page.Publication.Edit exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Browser
import Browser.Navigation as Nav
import Element as E exposing (..)
import Element.Input as Input
import Entity.Category exposing (Category)
import Entity.Publication as Publication
import Entity.Thumbnail as Thumbnail
import File exposing (File)
import File.Select as Select
import ReloadableData exposing (ReloadableWebData)
import Route
import Task
import UI.Card as Card
import UI.Heading as UI
import UI.Layout
import UI.Nav.Side
import UI.Parts.BreadCrumb as UI
import UI.Parts.Form as Form
import UI.Parts.Search
import UI.Poster as UI
import UI.ReloadableData
import UI.Spacing as UI



-- MODEL


type alias Model =
    { searchText : String
    , publication : ReloadableWebData Int Publication.MetaData
    }


init : Int -> ( Model, Cmd Msg )
init publicationId =
    ( { searchText = ""
      , publication = ReloadableData.Loading publicationId
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
    | UploadCompleted (ReloadableWebData Int String)


type Field
    = TitleField String
    | ISBNField String



-- VIEW


view : ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view categories model =
    UI.Layout.withSideNav
        { title = "Pustaka - Edit Publication"
        , sideNav =
            categories
                |> UI.Nav.Side.view LinkClicked UI.Nav.Side.NoSelection
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp) model.searchText)
        , content =
            UI.ReloadableData.view
                viewEdit
                model.publication
        }


viewEdit : Publication.MetaData -> Element Msg
viewEdit publication =
    column [ UI.spacing 1, width fill ]
        [ UI.breadCrumb []
        , row [ width fill, UI.spacing 1 ]
            [ viewPoster publication
            , column [ width fill, UI.spacing 1 ]
                [ UI.heading 1 "Edit Publication"
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


viewPoster : Publication.MetaData -> Element Msg
viewPoster publication =
    Card.bordered [ alignTop ]
        [ UI.poster publication.title publication.thumbnail
        , Input.button [ alignRight ] { onPress = Just BrowseClicked, label = text "Browse" }
        ]



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
            , Cmd.none
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
                |> ReloadableData.error
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
            ( model
            , model.publication
                |> ReloadableData.toMaybe
                |> Maybe.map
                    (\publication ->
                        Publication.uploadThumbnail
                            { publicationId = publication.id
                            , fileName = "thumbnail"
                            , file = file
                            , msg = UploadCompleted
                            }
                    )
                |> Maybe.withDefault Cmd.none
            )

        UploadCompleted remoteData ->
            remoteData
                |> ReloadableData.toMaybe
                |> Maybe.map
                    (\url ->
                        ( { model
                            | publication =
                                model.publication
                                    |> ReloadableData.map
                                        (\publication ->
                                            { publication | thumbnail = Thumbnail.url url }
                                        )
                          }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )


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
