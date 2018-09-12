module Page.ByCategory exposing
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
import Html.Extra
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (..)
import ReloadableData exposing (ReloadableWebData)
import Route
import Set
import UI.Css.Basics
import UI.Css.Color
import UI.Layout
import UI.Nav.Side
import UI.Parts.Search
import UI.ReloadableData


type alias Model =
    { categories : ReloadableWebData () (List Category)
    , selectedCategoryId : Maybe Int
    }


type Msg
    = NoOp
    | MenuItemClicked String
    | LoadCategoryCompleted (ReloadableWebData () (List Category))


init : Maybe Int -> ( Model, Cmd Msg )
init selectedCategoryId =
    ( { categories = ReloadableData.Loading ()
      , selectedCategoryId = selectedCategoryId
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
                |> UI.Nav.Side.withSearch (UI.Parts.Search.view (always NoOp))
        , content =
            [ categorySliderView key model
            ]
        }


categorySliderView : Nav.Key -> Model -> Html Msg
categorySliderView key model =
    div
        [ css
            [ position absolute
            , top zero
            , left zero
            , Css.width (pct 100)
            , backgroundColor (rgba 255 255 255 0.73)
            , UI.Css.Basics.containerShadow
            ]
        ]
        [ div [ css [ margin (rem 1) ] ]
            (UI.ReloadableData.view (categoriesView key model) model.categories)
        ]


categoriesView : Nav.Key -> Model -> List Category -> Html Msg
categoriesView key model categories =
    ul
        [ css
            [ listStyle none
            , padding zero
            , margin zero
            , displayFlex
            ]
        ]
        (categoryView key model "All" Nothing
            :: (categories
                    |> List.take 5
                    |> List.map (\category -> categoryView key model category.name (Just category.id))
               )
        )


categoryView : Nav.Key -> Model -> String -> Maybe Int -> Html Msg
categoryView key model categoryName maybeCategoryId =
    let
        listItemStyle =
            batch
                [ padding2 zero (rem 0.5)
                , borderRight3 (px 1) solid UI.Css.Color.black
                , color UI.Css.Color.black
                , lastOfType [ borderRight zero ]
                ]

        currentStyle =
            batch [ fontWeight bold ]
    in
    li
        [ css
            [ listItemStyle
            , if model.selectedCategoryId == maybeCategoryId then
                currentStyle

              else
                batch []
            ]
        ]
        [ case maybeCategoryId of
            Just categoryId ->
                Html.Extra.link MenuItemClicked
                    (Route.browseByCategoryIdUrl categoryId)
                    [ css [ color unset ] ]
                    [ text categoryName ]

            Nothing ->
                Html.Extra.link MenuItemClicked
                    Route.browseByCategoryUrl
                    [ css [ color unset ] ]
                    [ text categoryName ]
        ]
