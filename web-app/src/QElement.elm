module QElement exposing (..)

import Answer exposing (Answer)
import List.Extra exposing (swapAt)

type Q_element
    = Note NoteRecord
    | Question QuestionRecord


type alias NoteRecord =
    { id : Int
    , text : String
    }


type alias QuestionRecord =
    { id : Int
    , text : String
    , answers : List Answer
    , hint : String
    , typ : String
    , questionTime : String
    }


initQuestion : Q_element
initQuestion =
    Question
        { id = 0
        , text = "Beispielfrage"
        , answers = []
        , hint = ""
        , typ = ""
        , questionTime = ""
        }


--helper for changing order of elements
putElementDown : List Q_element -> Q_element -> List Q_element
putElementDown list element = 
    swapAt (getID element) ((getID element) + 1) (List.map (updateID (getID element) ((getID element) + 1)) list)
    --List.map (updateID (getID element) ((getID element) + 1)) list


putElementUp : List Q_element -> Q_element -> List Q_element
putElementUp list element = 
    swapAt (getID element) ((getID element) - 1) (List.map (updateID (getID element) ((getID element) - 1)) list)


putAnswerUp : Q_element -> Answer -> Q_element
putAnswerUp newElement answer =
    case newElement of 
        Note record ->
            Note record

        Question record ->
            Question { record | answers = swapAt answer.id (answer.id - 1) (List.map (updateAnsID answer.id (answer.id - 1)) record.answers)}


putAnswerDown : Q_element -> Answer -> Q_element
putAnswerDown newElement answer =
    case newElement of 
        Note record ->
            Note record

        Question record ->
            Question { record | answers = swapAt answer.id (answer.id + 1) (List.map (updateAnsID answer.id (answer.id + 1)) record.answers)}


setNewID : Q_element -> Int -> Q_element
setNewID element new =
    case element of 
        Note record ->
            Note { record | id = new }

        Question record -> 
            Question { record | id = new }


updateID : Int -> Int -> Q_element -> Q_element
updateID old new element =   
    if (getID element) == old then (setNewID element new)
    else if (getID element) == new then (setNewID element old) 
    else element


updateAnsID : Int -> Int -> Answer -> Answer
updateAnsID old new answer =
    if answer.id == old then { answer | id = new }
    else if answer.id == new then { answer | id = old }
    else answer

getAnswerWithID : Int -> Q_element -> Maybe Answer
getAnswerWithID id newElement = 
    case newElement of 
        Question record ->
            List.head (Tuple.first (List.partition (\e -> e.id == id) record.answers))

        Note record ->
            Nothing


getAntworten : Q_element -> List Answer                            
getAntworten element =
    case element of
        Question record ->
            record.answers

        Note record ->
            []


updateElementList : Q_element -> List Q_element -> List Q_element
updateElementList elementToUpdate list =
    List.map (updateElement elementToUpdate) list


updateElement : Q_element -> Q_element -> Q_element
updateElement elementToUpdate element =
    if getID element == getID elementToUpdate then
        elementToUpdate

    else
        element


getID : Q_element -> Int
getID element =
    case element of
        Question record ->
            record.id

        Note record ->
            record.id


getText : Q_element -> String
getText element =
    case element of
        Question record ->
            record.text

        Note record ->
            record.text


deleteItemFrom : Q_element -> List Q_element -> List Q_element
deleteItemFrom element list =
    Tuple.first (List.partition (\e -> e /= element) list)


deleteAnswerFromItem : Answer -> Q_element -> Q_element
deleteAnswerFromItem answer element =
    case element of 
        Question record ->
            Question { record | answers = Tuple.first (List.partition (\e -> e /= answer) record.answers) }
        Note record ->
            Note record


-- getters for input boxes


getElementText : Q_element -> String
getElementText element =
    case element of
        Question record ->
            record.text

        Note record ->
            record.text


getQuestionHinweis : Q_element -> String
getQuestionHinweis element =
    case element of
        Question record ->
            record.hint

        Note record ->
            "None"

getQuestionTyp : Q_element -> String
getQuestionTyp element =
    case element of
        Question record ->
            record.typ

        Note record ->
            "None"


getElementId : Q_element -> Int
getElementId elem = 
    case elem of
        Question a -> a.id
        Note a -> a.id