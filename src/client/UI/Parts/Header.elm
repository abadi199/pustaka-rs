module UI.Parts.Header exposing
    ( Visibility
    , header
    , hidden
    , isVisible
    , toCounter
    , toggle
    , visibilityFromCounter
    , visible
    )

import Css exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes as HA exposing (css)
import UI.Action as Action
import UI.Background as Background
import UI.Css.Grid as Grid
import UI.Events
import UI.Heading as Heading exposing (Level(..))
import UI.Icon as Icon


type Visibility
    = Hidden
    | Visible { counter : Float }


toggle : { counter : Float } -> Visibility -> Visibility
toggle { counter } visibility =
    case visibility of
        Visible _ ->
            Hidden

        Hidden ->
            Visible { counter = counter }


hidden : Visibility
hidden =
    Hidden


visible : { counter : Float } -> Visibility
visible =
    Visible


visibilityFromCounter : Float -> Visibility
visibilityFromCounter counter =
    if counter < 0 then
        hidden

    else
        visible { counter = counter }


isVisible : Visibility -> Bool
isVisible v =
    case v of
        Hidden ->
            False

        Visible _ ->
            True


toCounter : Visibility -> Maybe Float
toCounter visibility =
    case visibility of
        Hidden ->
            Nothing

        Visible { counter } ->
            Just counter


header :
    { visibility : Visibility
    , backUrl : String
    , onMouseMove : msg
    , onLinkClicked : String -> msg
    , title : String
    }
    -> Html msg
header { visibility, backUrl, onMouseMove, onLinkClicked, title } =
    case visibility of
        Hidden ->
            text ""

        Visible _ ->
            div
                [ css
                    [ width (pct 100)
                    , Grid.display
                    , Grid.templateColumns [ "auto", "1fr", "auto" ]
                    , Background.solidWhite
                    , boxShadow5 zero zero (px 5) (px 5) (rgba 0 0 0 0.25)
                    ]
                , UI.Events.onMouseMove onMouseMove
                ]
                [ Action.toHtml <|
                    Action.large <|
                        Action.link
                            { text = "Back"
                            , icon = Icon.previous Icon.small
                            , url = backUrl
                            , onClick = onLinkClicked
                            }
                , div
                    [ css
                        [ displayFlex
                        , alignItems center
                        , justifyContent center
                        ]
                    ]
                    [ Heading.heading One title ]
                , node "full-screen" [] []
                ]
