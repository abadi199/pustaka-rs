module UI.Spacing exposing
    ( Size(..)
    , margin
    , marginBottom
    , marginEach
    , marginLeft
    , marginRight
    , marginTop
    , padding
    , paddingBottom
    , paddingEach
    , paddingLeft
    , paddingRight
    , paddingTop
    )

import Css exposing (..)
import Html.Styled as H exposing (Attribute)


type Size
    = ExtraLarge
    | Large
    | Medium
    | Small
    | None


toFloat : Size -> Float
toFloat size =
    case size of
        ExtraLarge ->
            40

        Large ->
            20

        Medium ->
            10

        Small ->
            5

        None ->
            0


marginLeft : Size -> Style
marginLeft size =
    Css.marginLeft (px <| toFloat size)


marginRight : Size -> Style
marginRight size =
    Css.marginRight (px <| toFloat size)


marginBottom : Size -> Style
marginBottom size =
    Css.marginBottom (px <| toFloat size)


marginTop : Size -> Style
marginTop size =
    Css.marginTop (px <| toFloat size)


margin : Size -> Style
margin size =
    marginEach
        { top = size
        , bottom = size
        , right = size
        , left = size
        }


marginEach : { top : Size, right : Size, bottom : Size, left : Size } -> Style
marginEach { top, right, bottom, left } =
    margin4
        (px <| toFloat top)
        (px <| toFloat right)
        (px <| toFloat bottom)
        (px <| toFloat left)


paddingLeft : Size -> Style
paddingLeft size =
    Css.paddingLeft (px <| toFloat size)


paddingRight : Size -> Style
paddingRight size =
    Css.paddingRight (px <| toFloat size)


paddingBottom : Size -> Style
paddingBottom size =
    Css.paddingBottom (px <| toFloat size)


paddingTop : Size -> Style
paddingTop size =
    Css.paddingTop (px <| toFloat size)


padding : Size -> Style
padding size =
    paddingEach
        { top = size
        , bottom = size
        , right = size
        , left = size
        }


paddingEach : { top : Size, right : Size, bottom : Size, left : Size } -> Style
paddingEach { top, right, bottom, left } =
    padding4
        (px <| toFloat top)
        (px <| toFloat right)
        (px <| toFloat bottom)
        (px <| toFloat left)
