module Questionnaire exposing (..)

import Answer exposing (Answer, initAnswer)
import Condition exposing (Condition, initCondition)
import List.Extra exposing (swapAt, updateAt)
import QElement exposing (Q_element, initQuestion, getAnswerWithID, getText)


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
    , newCondition = initCondition
    , newAnswerID_Condition = ""

    --times
    , viewingTimeBegin = ""
    , viewingTimeEnd = ""
    , editTime = ""

    --newInputs
    , newElement = initQuestion
    , newAnswer = initAnswer
    }


getElementWithText : String -> Questionnaire -> Q_element
getElementWithText string questionnaire =
    case List.head (Tuple.first (List.partition (\e -> getText e == string) questionnaire.elements)) of 
        Just element ->
            element
        Nothing ->
            initQuestion


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


