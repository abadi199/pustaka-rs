module Reader.Comic exposing (reader)

import Css exposing (..)
import Entity.Publication as Publication
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Reader exposing (PageView(..))


reader : Publication.Data -> PageView -> Html msg
reader pub pageView =
    let
        imgStyle =
            batch [ Css.height (pct 100) ]
    in
    div
        [ css
            [ flex (int 1)
            , displayFlex
            , flexDirection row
            , Css.height (pct 100)
            ]
        ]
        (case pageView of
            DoublePage pageNum ->
                [ img
                    [ css [ imgStyle ]
                    , src <| "/api/publication/read/" ++ String.fromInt pub.id ++ "/page/" ++ String.fromInt pageNum
                    ]
                    []
                , img
                    [ css [ imgStyle ]
                    , src <| "/api/publication/read/" ++ String.fromInt pub.id ++ "/page/" ++ String.fromInt (pageNum + 1)
                    ]
                    []
                ]

            SinglePage pageNum ->
                [ img
                    [ css [ imgStyle ]
                    , src <| "/api/publication/read/" ++ String.fromInt pub.id ++ "/page/" ++ String.fromInt pageNum
                    ]
                    []
                ]
        )
