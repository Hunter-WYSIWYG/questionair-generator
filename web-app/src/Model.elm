module Model exposing (ModalType(..), Model, ValidationResult(..), isValidEditTime, isValidQuestionTime, isValidViewingTime, validate, validateQuestion)

import Questionnaire exposing (Questionnaire)


type alias Model =
    { questionnaire : Questionnaire

    --modals
    , showTitleModal : Bool
    , showEditTimeModal : Bool
    , showViewingTimeModal : Bool
    , showNewNoteModal : Bool
    , showNewQuestionModal : Bool
    , showNewAnswerModal : Bool

    --editQElement for EditQuestion and EditNote
    , editQElement : Bool
    , editAnswer : Bool

    --new inputs
    , inputTitle : String
    , validationResult : ValidationResult
    , inputEditTime : String
    , inputViewingTimeBegin : String
    , inputViewingTimeEnd : String
    , inputQuestionTime : String
    , questionValidationResult : ValidationResult

    --upload determines if the users wants to upload a questionnaire
    --if upload is false show UI to create new questionnaire
    , upload : Bool

    -- a page to edit Questionnaires
    , editQuestionnaire : Bool

    --Debug
    , tmp : String
    }


type ValidationResult
    = NotDone
    | Error String
    | ValidationOK


type ModalType
    = ViewingTimeModal
    | EditTimeModal
    | NewNoteModal
    | QuestionModal
    | TitleModal
    | AnswerModal



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
