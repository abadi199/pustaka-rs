module Entity.Progress exposing (Progress, percentage, toFloat)


type Progress
    = Percentage Float


percentage : Float -> Progress
percentage =
    Percentage


toFloat : Progress -> Float
toFloat progress =
    case progress of
        Percentage pct ->
            pct
