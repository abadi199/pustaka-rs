module UI.Css.MediaQuery exposing (forBigDesktopUp, forDesktopUp, forPhoneOnly, forTabletLandscapeUp, forTabletPortraitUp)

import Css exposing (Style)
import Css.Media exposing (withMediaQuery)


forPhoneOnly : List Style -> Style
forPhoneOnly =
    withMediaQuery [ "(max-width: 599px)" ]


forTabletPortraitUp : List Style -> Style
forTabletPortraitUp =
    withMediaQuery [ "(min-width: 600px)" ]


forTabletLandscapeUp : List Style -> Style
forTabletLandscapeUp =
    withMediaQuery [ "(min-width: 900px)" ]


forDesktopUp : List Style -> Style
forDesktopUp =
    withMediaQuery [ "(min-width: 1200px)" ]


forBigDesktopUp : List Style -> Style
forBigDesktopUp =
    withMediaQuery [ "(min-width: 1800px)" ]
