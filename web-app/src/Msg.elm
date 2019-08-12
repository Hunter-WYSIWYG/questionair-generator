module Msg exposing (Msg(..))

import Answer exposing (Answer)
import File exposing (File)
import Model exposing (ModalType, Model)
import QElement exposing (Q_element(..))
import Questionnaire exposing (Questionnaire)


type
    Msg
    --Changing Input
    = ChangeInputQuestionnaireTitle String
    | ChangeEditTime String
    | ChangeViewingTimeBegin String
    | ChangeViewingTimeEnd String
    | ChangeQuestionOrNoteText String
    | ChangeAnswerText String
    | ChangeQuestionNote String
    | ChangeQuestionType String
    | ChangeAnswerType String
    | ChangeQuestionNewAnswer Answer
    | ChangeQuestionTime String
      --Modals
    | ViewOrClose ModalType
      --Creates Condition
    | AddCondition String
    | AddConditionAnswer
    | AddAnswerToNewCondition String
      --Save input to questionnaire
    | SetQuestionnaireTitle
    | SetNote
    | SetQuestion
    | SetAnswer
    | SetPolarAnswers String
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
