module UI.Validator.String
    exposing
        ( maxLength
        , minLength
        , required
        )

import String
import UI.Validator as Validator exposing (Validator)
import UI.Validator.Internal as Internal


required : String -> Validator String
required errorMessage =
    \value ->
        if String.isEmpty value then
            Internal.ValidationError errorMessage
        else
            Internal.ValidationOk value


minLength : Int -> String -> Validator String
minLength length errorMessage =
    \value ->
        if String.length value < length then
            Internal.ValidationError errorMessage
        else
            Internal.ValidationOk value


maxLength : Int -> String -> Validator String
maxLength length errorMessage =
    \value ->
        if String.length value > length then
            Internal.ValidationError errorMessage
        else
            Internal.ValidationOk value
