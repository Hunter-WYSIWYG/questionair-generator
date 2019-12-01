module Questionnaire exposing (Questionnaire, getElementWithText, initQuestionnaire)

{-| Contains the type for the questionnaire and the initial state of the questionnaire in the model.


# Definition

@docs Questionnaire


# Public functions

@docs getElementWithText, initQuestionnaire

-}

import Answer exposing (Answer)
import Condition exposing (Condition)
import QElement exposing (Q_element(..))


{-| Der Typ, der den Fragebogen mit:
Titel, Liste von Elementen, "input-Bedingung" + zugehörige "input-Antwort" (bei deren Beantwortung gesprungen wird), Erscheinungs- und Bearbeitungszeiten, "Input-Frage/Anmerkung" und zugehörige "Input-Antwort" dieser Frage.
-}
type alias Questionnaire =
    { id : Int
    , priority : Int
    , title : String
    , elements : List Q_element
    , conditions : List Condition

    --times
    , viewingTime : String
    , reminderTimes : List String
    , editTime : String
    }


{-| Initial state of the questionnaire.
-}
initQuestionnaire : Questionnaire
initQuestionnaire =
    { id = 0
    , priority = 0
    , title = "Titel eingeben"
    , elements = []
    , conditions = []

    --times
    , viewingTime = ""
    , reminderTimes = []
    , editTime = ""
    }


{-| Returns the element with the specified text if it is in the list of elements of the questionnaire "questionnaire".
Otherwise, the "initial state" of a question is output.
-}
getElementWithText : String -> Questionnaire -> Q_element
getElementWithText string questionnaire =
    case List.head (Tuple.first (List.partition (\e -> QElement.getText e == string) questionnaire.elements)) of
        Just element ->
            element

        Nothing ->
            QElement.initQuestion