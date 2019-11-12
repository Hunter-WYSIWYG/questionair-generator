module Questionnaire exposing
    ( Questionnaire
    , getEditTime, getElementWithText, getViewingTime, initQuestionnaire
    )

{-| Enthält den Typ für den Fragebogen und den Anfangszustand des Fragebogens im Model.


# Definition

@docs Questionnaire


# Öffentliche Funktionen

@docs getEditTime, getElementWithText, getViewingTime, initQuestionnaire

-}

import Answer exposing (Answer)
import Condition exposing (Condition)
import QElement exposing (Q_element(..))


{-| Der Typ, der den Fragebogen mit:
Titel, Liste von Elementen, "input-Bedingung" + zugehörige "input-Antwort" (bei deren Beantwortung gesprungen wird), Erscheinungs- und Bearbeitungszeiten, "Input-Frage/Anmerkung" und zugehörige "Input-Antwort" dieser Frage.
-}
type alias Questionnaire =
    { title : String
    , elements : List Q_element
    , conditions : List Condition
    , newCondition : Condition
    , newAnswerID_Condition : String

    --times
    , viewingTime : String
    , reminderTimes : String
    , editTime : String

    --newInputs
    , newElement : Q_element
    , newAnswer : Answer
    }


{-| Anfangszustand des Fragebogens.
-}
initQuestionnaire : Questionnaire
initQuestionnaire =
    { title = "Titel eingeben"
    , elements = []
    , conditions = []
    , newCondition = Condition.initCondition
    , newAnswerID_Condition = ""

    --times
    , viewingTime = ""
    , reminderTimes = ""
    , editTime = ""

    --newInputs
    , newElement = QElement.initQuestion
    , newAnswer = Answer.initAnswer
    }


{-| TODO: ALS RÜCKGABETYP Maybe Q\_element VERWENDEN
Gibt das Element mit dem angegeben Text aus, falls es sich in der Liste von Elementen des Fragebogens questionnaire befindet.
Andernfalls wird der "Anfangszustand" einer Frage ausgegeben.
-}
getElementWithText : String -> Questionnaire -> Q_element
getElementWithText string questionnaire =
    case List.head (Tuple.first (List.partition (\e -> QElement.getText e == string) questionnaire.elements)) of
        Just element ->
            element

        Nothing ->
            QElement.initQuestion


{-| Gibt die Erscheinungszeit des Fragebogens aus.
-}
getViewingTime : Questionnaire -> String
getViewingTime questionnaire =
    if questionnaire.editTime == "" then
        "unbegrenzt"

    else
        questionnaire.editTime


{-| Gibt die Bearbeitungszeit des Fragebogens aus.
-}
getEditTime : Questionnaire -> String
getEditTime questionnaire =
    if questionnaire.viewingTime == "" then
        "unbegrenzt"

    else
        questionnaire.viewingTime