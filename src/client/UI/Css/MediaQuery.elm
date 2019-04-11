module UI.Css.MediaQuery exposing
    ( forBigDesktopUp
    , forBigDesktopUpPixel
    , forDesktopUp
    , forDesktopUpPixel
    , forPhoneOnly
    , forPhoneOnlyPixel
    , forTabletLandscapeUp
    , forTabletLandscapeUpPixel
    , forTabletPortraitUp
    , forTabletPortraitUpPixel
    )

import Css exposing (Style)
import Css.Media exposing (withMediaQuery)


forPhoneOnlyPixel : Int
forPhoneOnlyPixel =
    599


forPhoneOnly : List Style -> Style
forPhoneOnly =
    withMediaQuery [ "(max-width: " ++ String.fromInt forPhoneOnlyPixel ++ "px)" ]


forTabletPortraitUpPixel : Int
forTabletPortraitUpPixel =
    600


forTabletPortraitUp : List Style -> Style
forTabletPortraitUp =
    withMediaQuery [ "(min-width:" ++ String.fromInt forTabletPortraitUpPixel ++ "px)" ]


forTabletLandscapeUpPixel : Int
forTabletLandscapeUpPixel =
    900


forTabletLandscapeUp : List Style -> Style
forTabletLandscapeUp =
    withMediaQuery [ "(min-width: " ++ String.fromInt forTabletLandscapeUpPixel ++ "px)" ]


forDesktopUpPixel : Int
forDesktopUpPixel =
    1200


forDesktopUp : List Style -> Style
forDesktopUp =
    withMediaQuery [ "(min-width: " ++ String.fromInt forDesktopUpPixel ++ "px)" ]


forBigDesktopUpPixel : Int
forBigDesktopUpPixel =
    1800


forBigDesktopUp : List Style -> Style
forBigDesktopUp =
    withMediaQuery [ "(min-width: " ++ String.fromInt forBigDesktopUpPixel ++ "px)" ]
