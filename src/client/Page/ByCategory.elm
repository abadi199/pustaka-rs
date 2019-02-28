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
import ReloadableData exposing (ReloadableWebData)
import Route
import Set
import UI.Css.Basics
import UI.Css.Color
import UI.Icon as Icon
import UI.Layout
import UI.Link as UI
import UI.Nav.Side
import UI.Parts.Dialog as Dialog
import UI.Parts.Search
import UI.ReloadableData



-- MODEL


type alias Model =
    { categories : ReloadableWebData () (List Category)
    , selectedCategoryId : Maybe Int
    , searchText : String
    }


init : Maybe Int -> ( Model, Cmd Msg )
init selectedCategoryId =
    ( { categories = ReloadableData.Loading ()
      , selectedCategoryId = selectedCategoryId
      , searchText = ""
      }
    , Entity.Category.list LoadCategoryCompleted
    )



-- MESSAGE


type Msg
    = NoOp
    | MenuItemClicked String
    | LoadCategoryCompleted (ReloadableWebData () (List Category))



-- VIEW


view : Nav.Key -> ReloadableWebData () (List Category) -> Model -> Browser.Document Msg
view key categories model =
    UI.Layout.withSideNav
        { title = "Pustaka - Browse By Category"
        , sideNav =
            categories
                |> UI.Nav.Side.view MenuItemClicked UI.Nav.Side.BrowseByCategory
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp) model.searchText)
        , content = categorySliderView key model
        , dialog = Dialog.none
        }


categorySliderView : Nav.Key -> Model -> Element Msg
categorySliderView key model =
    el
        []
        (row
            []
            (UI.ReloadableData.view (categoriesView key model) model.categories
                :: [ UI.link
                        []
                        { msg = MenuItemClicked
                        , url = ""
                        , label =
                            row
                                []
                                [ Icon.expandMore Icon.small
                                , text "All Categories"
                                ]
                        }
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
                UI.link
                    []
                    { msg = MenuItemClicked
                    , url = Route.browseByCategoryIdUrl categoryId
                    , label = text categoryName
                    }

            Nothing ->
                UI.link
                    []
                    { msg = MenuItemClicked
                    , url = Route.browseByCategoryUrl
                    , label = text categoryName
                    }
        )



-- UPDATE


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MenuItemClicked url ->
            ( model, Nav.pushUrl key url )

        LoadCategoryCompleted categories ->
            ( { model | categories = categories }, Cmd.none )
