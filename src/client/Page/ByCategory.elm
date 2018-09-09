module Page.ByCategory exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Browser
import Browser.Navigation as Nav
import Entity.Category exposing (Category)
import Html.Styled as Html
import ReloadableData exposing (ReloadableWebData)
import Set
import UI.Layout
import UI.Nav.Side
import UI.Parts.Search


type alias Model =
    {}


type Msg
    = NoOp
    | MenuItemClicked String


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MenuItemClicked url ->
            ( model, Cmd.none )


view : Nav.Key -> ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view key categories model =
    UI.Layout.withSideNav
        { title = "Pustaka - By Category"
        , sideNav =
            categories
                |> UI.Nav.Side.view MenuItemClicked (Set.fromList [])
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp))
        , content = [ Html.text "By Category" ]
        }
