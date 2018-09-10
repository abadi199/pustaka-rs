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
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (css)
import ReloadableData exposing (ReloadableWebData)
import Set
import UI.Css.Basics
import UI.Css.Color
import UI.Layout
import UI.Nav.Side
import UI.Parts.Search


type alias Model =
    { categories : ReloadableWebData () (List Category) }


type Msg
    = NoOp
    | MenuItemClicked String


init : ( Model, Cmd Msg )
init =
    ( { categories = ReloadableData.NotAsked () }
    , Cmd.none
    )


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
    div
        [ css
            [ position absolute
            , top zero
            , left zero
            , width (pct 100)
            , backgroundColor (rgba 255 255 255 0.73)
            , UI.Css.Basics.containerShadow
            ]
        ]
        [ div [ css [ margin (rem 1) ] ]
            [ ul
                [ css
                    [ listStyle none
                    , padding zero
                    , margin zero
                    , displayFlex
                    ]
                ]
                [ li [ css [ listItemStyle, currentStyle ] ] [ text "All" ]
                , li [ css [ listItemStyle ] ] [ text "Programming Book" ]
                , li [ css [ listItemStyle ] ] [ text "Comics / Graphics Novel" ]
                , li [ css [ listItemStyle ] ] [ text "Science Fiction" ]
                , li [ css [ listItemStyle ] ] [ text "Novel" ]
                , li [ css [ listItemStyle ] ] [ text "Manga" ]
                ]
            ]
        ]
