module Page.ByCategory exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Assets exposing (Assets)
import Browser
import Browser.Navigation as Nav
import Entity.Category exposing (Category)
import Html.Styled as H exposing (..)
import ReloadableData exposing (ReloadableWebData)
import Route
import UI.Icon as Icon
import UI.Layout
import UI.Link as UI
import UI.ReloadableData



-- MODEL


type alias Model =
    { categories : ReloadableWebData () (List Category)
    , selectedCategoryId : Maybe Int
    , layoutState : UI.Layout.State Msg
    }


init : Maybe Int -> ( Model, Cmd Msg )
init selectedCategoryId =
    ( { categories = ReloadableData.Loading ()
      , selectedCategoryId = selectedCategoryId
      , layoutState = UI.Layout.initialState
      }
    , Entity.Category.list LoadCategoryCompleted
    )



-- MESSAGE


type Msg
    = NoOp
    | MenuItemClicked String
    | LoadCategoryCompleted (ReloadableWebData () (List Category))
    | LayoutStateChanged (UI.Layout.State Msg) (Cmd Msg)



-- VIEW


view : { a | key : Nav.Key, assets : Assets, favoriteCategories : ReloadableWebData () (List Category) } -> Model -> Browser.Document Msg
view { key, assets, favoriteCategories } model =
    UI.Layout.withNav
        { key = key
        , title = "Pustaka - Browse By Category"
        , assets = assets
        , content = categorySliderView key model
        , categories = favoriteCategories
        , state = model.layoutState
        , onStateChange = LayoutStateChanged
        }


categorySliderView : Nav.Key -> Model -> Html Msg
categorySliderView key model =
    div
        []
        [ div
            []
            (UI.ReloadableData.view (categoriesView key model) model.categories
                :: [ UI.link
                        []
                        { msg = MenuItemClicked
                        , url = ""
                        , label =
                            div
                                []
                                [ Icon.expandMore Icon.small
                                , text "All Categories"
                                ]
                        }
                   ]
            )
        ]


categoriesView : Nav.Key -> Model -> List Category -> Html Msg
categoriesView key model categories =
    div
        []
        (categoryView key model "All" Nothing
            :: (categories
                    |> List.take 5
                    |> List.map (\category -> categoryView key model category.name (Just category.id))
               )
        )


categoryView : Nav.Key -> Model -> String -> Maybe Int -> Html Msg
categoryView key model categoryName maybeCategoryId =
    div []
        [ case maybeCategoryId of
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
        ]



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

        LayoutStateChanged layoutState cmd ->
            ( { model | layoutState = layoutState }, cmd )
