module Questionnaire exposing
    ( Questionnaire
    , getEditTime, getElementWithText, getViewingTime, initQuestionnaire
    )

{-| Contains the type for the questionnaire and the initial state of the questionnaire in the model.


# Definition

@docs Questionnaire


# Public functions

@docs getEditTime, getElementWithText, getViewingTime, initQuestionnaire

-}

import Answer exposing (Answer)
import Condition exposing (Condition)
import QElement exposing (Q_element)


{-| Der Typ, der den Fragebogen mit:
Titel, Liste von Elementen, "input-Bedingung" + zugehörige "input-Antwort" (bei deren Beantwortung gesprungen wird), Erscheinungs- und Bearbeitungszeiten, "Input-Frage/Anmerkung" und zugehörige "Input-Antwort" dieser Frage.
-}
type alias Questionnaire =
    { title : String
    , elements : List Q_element
    , conditions : List Condition

    --times
    , viewingTime : String
    , reminderTimes : String
    , editTime : String
    }


{-| Initial state of the questionnaire.
-}
initQuestionnaire : Questionnaire
initQuestionnaire =
    { title = "Titel eingeben"
    , elements = []
    , conditions = []

    --times
    , viewingTime = ""
    , reminderTimes = ""
    , editTime = ""

    --newInputs
    --, newCondition = Condition.initCondition
    --, newAnswerID_Condition = ""
    --, newElement = QElement.initQuestion
    --, newAnswer = Answer.initAnswer
    }


{-| TODO: ALS RÜCKGABETYP Maybe Q\_element VERWENDEN
Returns the element with the specified text if it is in the list of elements of the questionnaire "questionnaire".
Otherwise, the "initial state" of a question is output.
-}
getElementWithText : String -> Questionnaire -> Q_element
getElementWithText string questionnaire =
    case List.head (Tuple.first (List.partition (\e -> QElement.getText e == string) questionnaire.elements)) of
        Just element ->
            element

        Nothing ->
            QElement.initQuestion


{-| Returns the appearance time of the questionnaire.
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
