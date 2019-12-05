module QElement exposing
    ( Q_element(..), NoteRecord, QuestionRecord
    , deleteAnswerFromItem, deleteItemFrom, getAnswerWithID, getAntworten, getElementId, getElementText, getID, getQuestionHinweis, getQuestionTyp, getText, initQuestion, putAnswerDown, putAnswerUp, putElementDown, putElementUp, setNewID, updateAnsID, updateElement, updateElementList, updateID )


{-| Contains the type for the elements of questionnaires (questions, annotations) and an initial state for the "input element" (newElement).


# Definition

@docs Q_element, NoteRecord, QuestionRecord


# Public functions

@docs deleteAnswerFromItem, deleteItemFrom, getAnswerWithID, getAntworten, getElementId, getElementText, getID, getQuestionHinweis, getQuestionTyp, getText, initQuestion, putAnswerDown, putAnswerUp, putElementDown, putElementUp, setNewID, updateAnsID, updateElement, updateElementList, updateID

-}

import Answer exposing (Answer)
import Utility as Utility


{-| Element of a questionnaire (question, annotation)
-}
type Q_element
    = Note NoteRecord
    | Question QuestionRecord


{-| Record of annotation with ID and text of the annotation.
-}
type alias NoteRecord =
    { id : Int
    , text : String
    }


{-| Record of a question with ID, text, list of answers, hint, question type and question time.
-}
type alias QuestionRecord =
    { id : Int
    , text : String
    , answers : List Answer
    , hint : String
    , typ : String
    , questionTime : String
    -- Größe der Tabelle bei Fragetyp Raster-Auswahl
    , tableSize : Int 
    -- Beschriftung der Tabelle bei Fragetyp Raster-Auswahl oder Prozentslider
    , topText : String
    , rightText : String
    , bottomText : String
    , leftText : String
    }


{-| Initial state of a question for the "input question" (newElement).
-}
initQuestion : Q_element
initQuestion =
    Question
        { id = 0
        , text = "Beispielfrage"
        , answers = []
        , hint = ""
        , typ = ""
        , questionTime = ""
        , tableSize = 0
        , topText = ""
        , rightText = ""
        , bottomText = "" 
        , leftText = ""
        }


{-| Helper function to raise the ID of a question. The question is then moved up in the table of questions by one position.
-}
putElementUp : List Q_element -> Q_element -> List Q_element
putElementUp list element =
    Utility.swapAt (getID element) (getID element - 1) (List.map (updateID (getID element) (getID element - 1)) list)


{-| Helper function for reducing the ID of a question. The question is then moved down one position in the table of questions.
-}
putElementDown : List Q_element -> Q_element -> List Q_element
putElementDown list element =
    Utility.swapAt (getID element) (getID element + 1) (List.map (updateID (getID element) (getID element + 1)) list)


{-| Helper function for increasing the ID of an answer. The question is then moved up one position in the table of answers to a question.
-}
putAnswerUp : Q_element -> Answer -> Q_element
putAnswerUp newElement answer =
    case newElement of
        Note record ->
            Note record

        Question record ->
            Question { record | answers = Utility.swapAt answer.id (answer.id - 1) (List.map (updateAnsID answer.id (answer.id - 1)) record.answers) }


{-| Helper function for reducing the ID of an answer. The question is then moved one position lower in the table of answers to a question.
-}
putAnswerDown : Q_element -> Answer -> Q_element
putAnswerDown newElement answer =
    case newElement of
        Note record ->
            Note record

        Question record ->
            Question { record | answers = Utility.swapAt answer.id (answer.id + 1) (List.map (updateAnsID answer.id (answer.id + 1)) record.answers) }


{-| Sets a new ID of a questionnaire item.
-}
setNewID : Q_element -> Int -> Q_element
setNewID element new =
    case element of
        Note record ->
            Note { record | id = new }

        Question record ->
            Question { record | id = new }


{-| Swaps the IDs of two elements with the IDs "old" and "new".
If the questionnaire element has the ID "old", the ID is set to "new". If the ID is "new", the ID is set to "old".
-}
updateID : Int -> Int -> Q_element -> Q_element
updateID old new element =
    if getID element == old then
        setNewID element new

    else if getID element == new then
        setNewID element old

    else
        element


{-| Swaps the IDs of two answers with the IDs "old" and "new".
If the answer has the ID "old", the ID is set to "new". If the ID is "new", the ID is set to "old".
-}
updateAnsID : Int -> Int -> Answer -> Answer
updateAnsID old new answer =
    if answer.id == old then
        { answer | id = new }

    else if answer.id == new then
        { answer | id = old }

    else
        answer


{-| Finds the answer with the given ID within a question.
-}
getAnswerWithID : Int -> Q_element -> Maybe Answer
getAnswerWithID id newElement =
    case newElement of
        Question record ->
            List.head (Tuple.first (List.partition (\e -> e.id == id) record.answers))

        Note record ->
            Nothing


{-| Returns the answers to a question.
-}
getAntworten : Q_element -> List Answer
getAntworten element =
    case element of
        Question record ->
            record.answers

        Note record ->
            []


{-| Updates the specified item in a list of items.
A question is searched with the ID of elementToUpdate in the list "list" and replaced by elementToUpdate.
-}
updateElementList : Q_element -> List Q_element -> List Q_element
updateElementList elementToUpdate list =
    List.map (updateElement elementToUpdate) list


{-| Replaces element "element" with elementToUpdate if the IDs of both questionnaire elements match.
-}
updateElement : Q_element -> Q_element -> Q_element
updateElement elementToUpdate element =
    if getID element == getID elementToUpdate then
        elementToUpdate

    else
        element


{-| TODO: WIRKLICH NÖTOG?
Returns the ID of a questionnaire item.
-}
getID : Q_element -> Int
getID element =
    case element of
        Question record ->
            record.id

        Note record ->
            record.id


{-| TODO: WIRKLICH NÖTOG?
Returns the text of a questionnaire item.
-}
getText : Q_element -> String
getText element =
    case element of
        Question record ->
            record.text

        Note record ->
            record.text


{-| Deletes the questionnaire item "element" in the list "list".
It searches for the item in the list that has the same ID as "element".
-}
deleteItemFrom : Q_element -> List Q_element -> List Q_element
deleteItemFrom element list =
    let 
        elementId = getElementId element
        deletedList = Tuple.first (List.partition (\e -> e /= element) list)
        firstList = Tuple.first (List.partition (\e -> getElementId e < elementId) deletedList)
        secondList = Tuple.first (List.partition (\e -> getElementId e > elementId) deletedList)
    in
        List.append firstList (updateIdsAfterDelete secondList)


{-| Deletes the specified answer "answer" from a question element.
It looks for the answer in the list that has the same ID as "answer".
-}
deleteAnswerFromItem : Answer -> Q_element -> Q_element
deleteAnswerFromItem answer element =
    case element of
        Question record ->
            Question { record | answers = Tuple.first (List.partition (\e -> e /= answer) record.answers) }

        Note record ->
            Note record


{-| TODO: ENFERNEN! DUPLIZIERT getText
-}
getElementText : Q_element -> String
getElementText element =
    case element of
        Question record ->
            record.text

        Note record ->
            record.text


{-| Returns the hint of a question.
-}
getQuestionHinweis : Q_element -> String
getQuestionHinweis element =
    case element of
        Question record ->
            record.hint

        Note record ->
            "None"


{-| Returns the type of a question
-}
getQuestionTyp : Q_element -> String
getQuestionTyp element =
    case element of
        Question record ->
            record.typ

        Note record ->
            "None"


{-| TODO: ENFERNEN! DUPLIZIERT getID
-}
getElementId : Q_element -> Int
getElementId elem =
    case elem of
        Question a ->
            a.id

        Note a ->
            a.id
{- set- und get-Funktionen für Variablen für Fragetyp Raster-Auswahl
-}


updateIdsAfterDelete : List Q_element -> List Q_element
updateIdsAfterDelete list = List.map getElementIdForDelete list

getElementIdForDelete : Q_element -> Q_element
getElementIdForDelete elem =
    case elem of
        Question record ->
            Question { record | id = (sub record.id)}

        Note record ->
            Note { record | id = (sub record.id) }

sub: Int -> Int 
sub id = id - 1