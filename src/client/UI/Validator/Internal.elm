module UI.Validator.Internal
    exposing
        ( ValidationResult(..)
        )


type ValidationResult value
    = ValidationError String
    | ValidationOk value
