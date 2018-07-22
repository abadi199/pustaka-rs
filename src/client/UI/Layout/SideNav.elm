module UI.Layout.SideNav exposing (view)

import Browser.Navigation as Nav
import Entity.Category exposing (Category)
import Html exposing (..)
import Html.Attributes exposing (..)
import ReloadableData exposing (ReloadableData(..), ReloadableWebData)
import Route
import Set exposing (Set)
import Tree exposing (Tree)
import UI.Error
import UI.Loading
import UI.Menu


view : (Int -> msg) -> Set Int -> ReloadableWebData () (Tree Category) -> Html msg -> Html msg
view onCategoryClicked selectedCategoryIds categoriesData content =
    div [ style "display" "grid", style "grid-template-columns" "300px auto" ]
        [ sideNav onCategoryClicked selectedCategoryIds categoriesData
        , content
        ]


sideNav : (Int -> msg) -> Set Int -> ReloadableWebData () (Tree Category) -> Html msg
sideNav onCategoryClicked selectedCategoryIds data =
    div []
        (case data of
            NotAsked _ ->
                []

            Loading _ ->
                [ UI.Loading.view ]

            Reloading categories ->
                [ UI.Loading.view, categoriesView onCategoryClicked selectedCategoryIds categories ]

            Success categories ->
                [ categoriesView onCategoryClicked selectedCategoryIds categories ]

            Failure error _ ->
                [ UI.Error.view <| Debug.toString error ]

            FailureWithData error categories ->
                [ categoriesView onCategoryClicked selectedCategoryIds categories, UI.Error.view <| Debug.toString error ]
        )


categoriesView : (Int -> msg) -> Set Int -> Tree Category -> Html msg
categoriesView onCategoryClicked selectedCategoryIds categories =
    categories
        |> Tree.map
            (\category ->
                { text = category.name
                , selected = Set.member category.id selectedCategoryIds
                , link = UI.Menu.internalLink (onCategoryClicked category.id) (Route.categoryUrl category.id)
                }
            )
        |> UI.Menu.view
