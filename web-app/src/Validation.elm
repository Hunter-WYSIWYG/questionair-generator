module Validation exposing (ValidationResult, validate)

import Model exposing (..)

type ValidationResult
    = NotDone
    | Error String
    | ValidationOK

-- Input Validation


validate : Model -> ValidationResult
validate model =
    if not (isValidEditTime model.inputEditTime) then
        Error "Die Bearbeitungszeit muss das Format HH:MM haben"

    else if not (isValidViewingTime model.inputViewingTimeBegin) then
        Error "Die Zeiten müssen das Format DD:MM:YYYY:HH:MM haben"

    else if not (isValidViewingTime model.inputViewingTimeEnd) then
        Error "Die Zeiten müssen das Format DD:MM:YYYY:HH:MM haben"
    else
        ValidationOK

isValidViewingTime : String -> Bool
isValidViewingTime viewingTime =
    not (String.length viewingTime /= 16 && String.length viewingTime /= 0)


isValidEditTime : String -> Bool
isValidEditTime editTime =
    not (String.length editTime /= 5 && String.length editTime /= 0)

validateQuestion : String -> ValidationResult
validateQuestion questionTime =
            if not (isValidQuestionTime questionTime) then
                Error "Die Zeiten müssen das Format HH:MM:SS haben"
            else
                ValidationOK

isValidQuestionTime : String -> Bool
isValidQuestionTime questionTime = 
    not (String.length questionTime /= 8 && String.length questionTime /= 0)