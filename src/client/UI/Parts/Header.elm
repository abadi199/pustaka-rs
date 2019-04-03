module UI.Parts.Header exposing
    ( Visibility
    , header
    , hidden
    , isVisible
    , toCounter
    , visibilityFromCounter
    , visible
    )

import Html.Styled as H exposing (..)
import Route
import UI.Action as Action
import UI.Background as Background
import UI.Events
import UI.Heading as Heading
import UI.Icon as Icon
import UI.Spacing as UI


type Visibility
    = Hidden
    | Visible { counter : Float }


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
            none

        Visible _ ->
            row
                [ width fill
                , Background.solidWhite
                , Border.shadow
                    { offset = ( 0, 0 )
                    , size = 0
                    , blur = 10
                    , color = rgba 0 0 0 0.5
                    }
                , UI.padding -5
                , UI.Events.onMouseMove onMouseMove
                ]
                [ Action.toElement <|
                    Action.large <|
                        Action.link
                            { text = "Back"
                            , icon = Icon.previous Icon.small
                            , url = backUrl
                            , onClick = onLinkClicked
                            }
                , el [ centerX ] (Heading.heading 1 title)
                ]
