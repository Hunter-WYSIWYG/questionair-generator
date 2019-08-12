module Model exposing (..)

import Questionnaire exposing (..)
import Validation exposing (..)

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