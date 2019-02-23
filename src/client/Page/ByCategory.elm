module Page.ByCategory exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Browser
import Browser.Navigation as Nav
import Element as E exposing (..)
import Entity.Category exposing (Category)
import Html.Extra
import ReloadableData exposing (ReloadableWebData)
import Route
import Set
import UI.Css.Basics
import UI.Css.Color
import UI.Icon as Icon
import UI.Layout
import UI.Nav.Side
import UI.Parts.Search
import UI.ReloadableData


type alias Model =
    { categories : ReloadableWebData () (List Category)
    , selectedCategoryId : Maybe Int
    , searchText : String
    }


type Msg
    = NoOp
    | MenuItemClicked String
    | LoadCategoryCompleted (ReloadableWebData () (List Category))


init : Maybe Int -> ( Model, Cmd Msg )
init selectedCategoryId =
    ( { categories = ReloadableData.Loading ()
      , selectedCategoryId = selectedCategoryId
      , searchText = ""
      }
    , Entity.Category.list LoadCategoryCompleted
    )


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MenuItemClicked url ->
            ( model, Nav.pushUrl key url )

        LoadCategoryCompleted categories ->
            ( { model | categories = categories }, Cmd.none )


view : Nav.Key -> ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view key categories model =
    UI.Layout.withSideNav
        { title = "Pustaka - Browse By Category"
        , sideNav =
            categories
                |> UI.Nav.Side.view MenuItemClicked UI.Nav.Side.BrowseByCategory
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp) model.searchText)
        , content = categorySliderView key model
        }


categorySliderView : Nav.Key -> Model -> Element Msg
categorySliderView key model =
    el
        []
        (row
            []
            (UI.ReloadableData.view (categoriesView key model) model.categories
                :: [ Html.Extra.link MenuItemClicked
                        []
                        ""
                        (row
                            []
                            [ Icon.expandMore
                            , text "All Categories"
                            ]
                        )
                   ]
            )
        )


categoriesView : Nav.Key -> Model -> List Category -> Element Msg
categoriesView key model categories =
    row
        []
        (categoryView key model "All" Nothing
            :: (categories
                    |> List.take 5
                    |> List.map (\category -> categoryView key model category.name (Just category.id))
               )
        )


categoryView : Nav.Key -> Model -> String -> Maybe Int -> Element Msg
categoryView key model categoryName maybeCategoryId =
    el []
        (case maybeCategoryId of
            Just categoryId ->
                Html.Extra.link MenuItemClicked
                    []
                    (Route.browseByCategoryIdUrl categoryId)
                    (text categoryName)

            Nothing ->
                Html.Extra.link MenuItemClicked
                    []
                    Route.browseByCategoryUrl
                    (text categoryName)
        )
