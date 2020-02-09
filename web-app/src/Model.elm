module Model exposing
    ( Model, ModalType(..), Msg(..), ValidationResult(..)
    , initModel, validateQuestionTime
    )

{-| Contains the types for the model, the modals, the messages, and the ValidationResult. Also includes the initial state of the model.


# Definition

@docs Model, ModalType, Msg, ValidationResult


# Public functions

@docs initModel, isValidEditTime, isValidQuestionTime, isValidViewingTime, validateQuestionTime

-}

import Answer exposing (Answer)
import Condition exposing (Condition)
import File exposing (File)
import Json.Decode as JDecode
import QElement exposing (Q_element)
import Questionnaire exposing (Questionnaire)
import Time exposing (..)


{-| The model for the WebApp.
-}
type alias Model =
    { questionnaire : Questionnaire

    --modals
    , showTitleModal : Bool
    , showEditTimeModal : Bool
    , showViewingTimeModal : Bool
    , showNewNoteModal : Bool
    , showNewQuestionModal : Bool
    , showNewAnswerModal : Bool
    , showNewConditionModalOverview : Bool
    , showNewConditionModalCreate : Bool

    --editQElement for EditQuestion and EditNote
    , editQElement : Bool
    , editAnswer : Bool
    , editCondition : Bool

    --new inputs
    , inputTitle : String
    , inputPriority : Int
    , validationResult : ValidationResult
    , inputEditTime : String
    , inputViewingTime : String
    , inputReminderTimes : List String
    , inputQuestionTime : String
    , questionValidationResult : ValidationResult
    , questionTimeValidationResult : ValidationResult
    , inputParentId : Int
    , inputChildId : Int
    , newAnswerID_Condition : String
    , newCondition : Condition
    , newElement : Q_element
    , newAnswer : Answer
    , inputQuestionTimeMinutes : String
    , inputQuestionTimeSeconds : String

    --upload determines if the users wants to upload a questionnaire
    --if upload is false show UI to create new questionnaire
    , upload : Bool

    -- a page to edit Questionnaires
    , editQuestionnaire : Bool
    }


{-| The result of the validation of the model.
-}
type ValidationResult
    = NotDone
    | Error String
    | ValidationOK


{-| The types of models that can be opened.
-}
type ModalType
    = ViewingTimeModal
    | EditTimeModal
    | NewNoteModal
    | QuestionModal
    | TitleModal
    | AnswerModal
    | ConditionModalOverview
    | ConditionModalCreate


{-| The messages of the WebApp.
-}
type
    Msg
    --Changing Input
    = ChangeInputQuestionnaireTitle String
    | ChangeInputPriority String
    | ChangeQuestionOrNoteText String
    | ChangeAnswerText String
    | ChangeQuestionNote String
    | ChangeQuestionType String
    | ChangeAnswerType String
    | ChangeQuestionNewAnswer Answer
    | ChangeEditTime String
    | ChangeReminderTimes JDecode.Value
    | ChangeViewingTime String
    | ChangeQuestionTimeMinutes String
    | ChangeQuestionTimeSeconds String
      --Modals
    | ViewOrClose ModalType
      --Creates Condition
    | AddAnswerToNewCondition String
    | ChangeInputParentId String
    | ChangeInputChildId String
    | ChangeInputAnswerId String
      --Save input to questionnaire
    | SetQuestionnaireTitlePriority
    | SetNote
    | SetQuestion
    | SetAnswer
    | SetConditions
    | SetPolarMin String
    | SetPolarMax String
    | SetTableSize String
    | SetTopText String
    | SetRightText String
    | SetBottomText String
    | SetLeftText String
      --Edit existing elements or answers
    | EditQuestion Q_element
    | EditNote Q_element
    | EditAnswer Answer
    | EditCondition Condition
    | EditQuestionnaire
      --Change order of elements
    | PutUpEl Q_element
    | PutDownEl Q_element
    | PutUpAns Answer
    | PutDownAns Answer
      --Delete existing elements or answers
    | DeleteItem Q_element
    | DeleteAnswer Answer
    | DeleteCondition Condition
      --Validation of times
    | Submit
      --Everything releated to upload
    | EnterUpload
    | JsonRequested
    | JsonSelected File
    | JsonLoaded String
      --Everything releated to download
    | DownloadQuestionnaire


{-| The initial state of the model.
-}
initModel : Model
initModel =
  { questionnaire = Questionnaire.initQuestionnaire

    --modals
    , showTitleModal = False
    , showEditTimeModal = False
    , showViewingTimeModal = False
    , showNewNoteModal = False
    , showNewQuestionModal = False
    , showNewAnswerModal = False
    , showNewConditionModalOverview = False
    , showNewConditionModalCreate = False

    --editQElement for EditQuestion and EditNote
    , editQElement = False
    , editAnswer = False
    , editCondition = False

    --new inputs
    , inputTitle = ""
    , inputPriority = 0
    , validationResult = NotDone
    , inputEditTime = ""
    , inputViewingTime = ""
    , inputReminderTimes = []
    , inputQuestionTime = ""
    , questionValidationResult = NotDone
    , questionTimeValidationResult = NotDone
    , inputParentId = -1
    , inputChildId = -1
    , newCondition = Condition.initCondition
    , newAnswerID_Condition = ""
    , newElement = QElement.initQuestion
    , newAnswer = Answer.initAnswer
    , inputQuestionTimeMinutes = ""
    , inputQuestionTimeSeconds = ""

    --upload determines if the users wants to upload a questionnaire
    --if upload is false show UI to create new questionnaire
    , upload = False

    -- a page to edit Questionnaires
    , editQuestionnaire = True
  }

{-| Method for validating the question time format.
-}
validateQuestionTime : String -> String -> ValidationResult
validateQuestionTime minutes seconds =
    if (String.contains "-" minutes)||(String.contains "-" seconds)
    then Error "Keine negativen Zeiten!"
    else    case String.toInt seconds of
                Just sec -> if sec<60
                            then ValidationOK
                            else Error "Zu hohe Sekundenzahl!"
                Nothing -> ValidationOK

