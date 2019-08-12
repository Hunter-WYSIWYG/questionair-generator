module Questionnaire exposing (Questionnaire, getEditTime, getElementWithText, getViewingTime, initQuestionnaire)

import Answer exposing (Answer)
import Condition exposing (Condition)
import List.Extra as LExtra
import QElement exposing (Q_element)


type alias Questionnaire =
    { title : String
    , elements : List Q_element
    , conditions : List Condition
    , newCondition : Condition
    , newAnswerID_Condition : String

    --times
    , viewingTimeBegin : String
    , viewingTimeEnd : String
    , editTime : String

    --newInputs
    , newElement : Q_element
    , newAnswer : Answer
    }



--Inits


initQuestionnaire : Questionnaire
initQuestionnaire =
    { title = "Titel eingeben"
    , elements = []
    , conditions = []
    , newCondition = Condition.initCondition
    , newAnswerID_Condition = ""

    --times
    , viewingTimeBegin = ""
    , viewingTimeEnd = ""
    , editTime = ""

    --newInputs
    , newElement = QElement.initQuestion
    , newAnswer = Answer.initAnswer
    }


getElementWithText : String -> Questionnaire -> Q_element
getElementWithText string questionnaire =
    case List.head (Tuple.first (List.partition (\e -> QElement.getText e == string) questionnaire.elements)) of
        Just element ->
            element

        Nothing ->
            QElement.initQuestion


getViewingTime : Questionnaire -> String
getViewingTime questionnaire =
    if questionnaire.editTime == "" then
        "unbegrenzt"

    else
        questionnaire.editTime


getEditTime : Questionnaire -> String
getEditTime questionnaire =
    if questionnaire.viewingTimeBegin == "" then
        "unbegrenzt"

    else
        "Von " ++ questionnaire.viewingTimeBegin ++ " Bis " ++ questionnaire.viewingTimeEnd
