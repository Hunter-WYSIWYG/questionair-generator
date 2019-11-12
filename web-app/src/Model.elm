module Model exposing
    ( Model, ModalType(..), Msg(..), ValidationResult(..)
    , initModel, isValidQuestionTime, validateQuestion
    )

{-| Enthält die Typen für das Model, die Modale, die Messages und das ValidationResult. Enthällt außerdem den Anfangszustand des Models.


# Definition

@docs Model, ModalType, Msg, ValidationResult


# Öffentliche Funktionen

@docs initModel, isValidEditTime, isValidQuestionTime, isValidViewingTime, validateQuestion

-}

import Answer exposing (Answer)
import Condition exposing (Condition)
import File exposing (File)
import QElement exposing (Q_element)
import Questionnaire exposing (Questionnaire)
import Time exposing (..)


{-| Das Model für die Webanwendung.
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
    , showNewConditionModal1 : Bool
    , showNewConditionModal2 : Bool

    --editQElement for EditQuestion and EditNote
    , editQElement : Bool
    , editAnswer : Bool

    --new inputs
    , inputTitle : String
    , validationResult : ValidationResult
    , inputEditTime : String
    , inputViewingTime : String
    , inputReminderTimes : String
    , inputQuestionTime : String
    , questionValidationResult : ValidationResult
    , inputParentId : Int
    , inputChildId : Int
    , newAnswerID_Condition : String
    , newCondition : Condition

    --upload determines if the users wants to upload a questionnaire
    --if upload is false show UI to create new questionnaire
    , upload : Bool

    -- a page to edit Questionnaires
    , editQuestionnaire : Bool
    }


{-| Das Ergebnis der Validierung des Models.
-}
type ValidationResult
    = NotDone
    | Error String
    | ValidationOK


{-| Die Modaltypen, die geöffnet werden können.
-}
type ModalType
    = ViewingTimeModal
    | EditTimeModal
    | NewNoteModal
    | QuestionModal
    | TitleModal
    | AnswerModal
    | ConditionModal1
    | ConditionModal2


{-| Die Messages der Webanwendung.
-}
type
    Msg
    --Changing Input
    = ChangeInputQuestionnaireTitle String
    | ChangeQuestionOrNoteText String
    | ChangeAnswerText String
    | ChangeQuestionNote String
    | ChangeQuestionType String
    | ChangeAnswerType String
    | ChangeQuestionNewAnswer Answer
    | ChangeEditTime String
    | ChangeReminderTimes String
    | ChangeViewingTime String
      --Modals
    | ViewOrClose ModalType
      --Creates Condition
    | AddCondition
    | AddConditionAnswer
    | AddAnswerToNewCondition String
    | ChangeInputParentId String
    | ChangeInputChildId String
      --Save input to questionnaire
    | SetQuestionnaireTitle
    | SetNote
    | SetQuestion
    | SetAnswer
    | SetConditions
    | SetPolarAnswers String
    | SetTableSize String
    | SetTopText String
    | SetRightText String
    | SetBottomText String
    | SetLeftText String
      --Edit existing elements or answers
    | EditQuestion Q_element
    | EditNote Q_element
    | EditAnswer Answer
    | EditQuestionnaire
      --Change order of elements
    | PutUpEl Q_element
    | PutDownEl Q_element
    | PutUpAns Answer
    | PutDownAns Answer
      --Delete existing elements or answers
    | DeleteItem Q_element
    | DeleteAnswer Answer
      --Validation of times
    | Submit
      --Everything releated to upload
    | LeaveOrEnterUpload
    | EnterUpload
    | JsonRequested
    | JsonSelected File
    | JsonLoaded String
      --Everything releated to download
    | DownloadQuestionnaire


{-| Der Anfangszustand des Models.
-}
initModel : () -> ( Model, Cmd Msg )
initModel _ =
    ( { questionnaire = Questionnaire.initQuestionnaire

      --modals
      , showTitleModal = False
      , showEditTimeModal = False
      , showViewingTimeModal = False
      , showNewNoteModal = False
      , showNewQuestionModal = False
      , showNewAnswerModal = False
      , showNewConditionModal1 = False
      , showNewConditionModal2 = False

      --editQElement for EditQuestion and EditNote
      , editQElement = False
      , editAnswer = False

      --new inputs
      , inputTitle = ""
      , validationResult = NotDone
      , inputEditTime = ""
      , inputViewingTime = ""
      , inputReminderTimes = ""
      , inputQuestionTime = ""
      , questionValidationResult = NotDone
      , inputParentId = -1
      , inputChildId = -1
      , newCondition = Condition.initCondition
      , newAnswerID_Condition = ""

      --upload determines if the users wants to upload a questionnaire
      --if upload is false show UI to create new questionnaire
      , upload = False

      -- a page to edit Questionnaires
      , editQuestionnaire = True
      }
    , Cmd.none
    )


{-| Methode zur Validierung des Fragenzeitformats.
-}
validateQuestion : String -> ValidationResult
validateQuestion questionTime =
    if not (isValidQuestionTime questionTime) then
        Error "Die Zeiten müssen das Format HH:MM:SS haben"

    else
        ValidationOK


{-| Methode zur Validierung der Länge der Fragenzeit.
-}
isValidQuestionTime : String -> Bool
isValidQuestionTime questionTime =
    not (String.length questionTime /= 8 && String.length questionTime /= 0)
