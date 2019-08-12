module Questionnaire exposing (..)

import List.Extra exposing (swapAt, updateAt)


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

type Q_element
    = Note NoteRecord
    | Question QuestionRecord

type alias Condition = 
    { parent_id : Int
    , child_id : Int
    , answers : List Answer
    , isValid : Bool }

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


type alias Answer =
    { id : Int
    , text : String

    --type can be "free" or "regular"
    , typ : String
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

initAnswer : Answer
initAnswer =
    { id = 0
    , text = ""
    --type can be "free" or "regular"
    , typ = ""
    }

initCondition : Condition
initCondition = 
    { parent_id = -1
    , child_id = -1
    , answers = []
    , isValid = False
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


updateConditionWithIdTo : List Condition -> Int -> Int -> List Condition
updateConditionWithIdTo list old new =
    List.map (updateConditionID old new) list


updateConditionID : Int -> Int -> Condition -> Condition
updateConditionID old new condition = 
    { condition | child_id = getNewConditionID condition.child_id old new
                , parent_id = getNewConditionID condition.parent_id old new }
    -- das setzt child und parent ids auf den gleichen wert! TODO
    
getNewConditionID : Int -> Int -> Int -> Int
getNewConditionID cond_id old new =
    if cond_id == old then new
    else if cond_id == new then old
    else cond_id


updateConditionAnswers : List Condition -> Int -> Int -> List Condition
updateConditionAnswers list old new = 
    List.map (updateConditionWithAnswer old new) list


updateConditionWithAnswer : Int -> Int -> Condition -> Condition 
updateConditionWithAnswer old new condition = 
    { condition | answers = List.map (updateConditionAnswer old new) condition.answers }


updateConditionAnswer : Int -> Int -> Answer -> Answer
updateConditionAnswer old new answer = 
    if answer.id == old then { answer | id = new }
    else if answer.id == new then { answer | id = old }
    else answer


deleteConditionWithElement : List Condition -> Int -> List Condition
deleteConditionWithElement list id = 
    deleteConditionWithParent (deleteConditionWithChild list id) id


deleteConditionWithParent : List Condition -> Int -> List Condition
deleteConditionWithParent list id = 
    Tuple.first (List.partition (\e -> e.parent_id /= id) list)


deleteConditionWithChild : List Condition -> Int -> List Condition
deleteConditionWithChild list id = 
    Tuple.first (List.partition (\e -> e.child_id /= id) list)


deleteAnswerInCondition : Int -> Condition -> Condition
deleteAnswerInCondition id condition =
    { condition | answers = deleteCondAnswer condition.answers id }


deleteCondAnswer : List Answer -> Int -> List Answer
deleteCondAnswer list id =
    Tuple.first (List.partition (\answer -> answer.id /= id) list) 


setParentChildInCondition : Int -> Int -> Condition -> Condition
setParentChildInCondition parent child condition =
    { condition
        | parent_id = parent
        , child_id = child 
        , isValid = True
    }


setAnswersInCondition : List Answer -> Condition -> Condition
setAnswersInCondition list condition = 
    { condition
        | answers = list
    }


addAnswerOfQuestionToCondition : Int -> Q_element -> Condition -> Condition
addAnswerOfQuestionToCondition id newElement condition =
    case getAnswerWithID id newElement of 
        Just newAnswer ->
            { condition | answers = condition.answers ++ [newAnswer]}
        Nothing ->
            condition


removeConditionFromCondList : Condition -> List Condition -> List Condition
removeConditionFromCondList condition list = 
    Tuple.first (List.partition (\c -> c.parent_id /= condition.parent_id) list)


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


setPredefinedAnswers : String -> List Answer
setPredefinedAnswers questionType =
    if questionType == "Ja/Nein Frage" then
        [ regularAnswer 0 "Ja", regularAnswer 1 "Nein" ]

    else
        []


regularAnswer : Int -> String -> Answer
regularAnswer int string =
    { id = int
    , text = string
    , typ = "regular"
    }


freeAnswer : Int -> String -> Answer                                        
freeAnswer int string = 
    { id = int
    , text = string
    , typ = "free" 
    }


getUnipolarAnswers : String -> List Answer
getUnipolarAnswers string =
    case String.toInt string of
        Nothing ->
            []

        Just val ->
            getAnswersWithRange 1 val 0


getBipolarAnswers : String -> List Answer
getBipolarAnswers string =
    case String.toInt string of
        Nothing ->
            []

        Just val ->
            getAnswersWithRange -val val 0


getAnswersWithRange : Int -> Int -> Int -> List Answer
getAnswersWithRange begin end index =
    if begin == end then
        [ regularAnswer index (String.fromInt end) ]

    else
        [ regularAnswer index (String.fromInt begin) ] ++ getAnswersWithRange (begin + 1) end (index + 1)


updateElementList : Q_element -> List Q_element -> List Q_element
updateElementList elementToUpdate list =
    List.map (updateElement elementToUpdate) list


updateAnswerList : Answer -> List Answer -> List Answer
updateAnswerList answerToUpdate list =
    List.map (updateAnswer answerToUpdate) list


updateElement : Q_element -> Q_element -> Q_element
updateElement elementToUpdate element =
    if getID element == getID elementToUpdate then
        elementToUpdate

    else
        element


updateCondition : Condition -> Condition -> Condition
updateCondition conditionToUpdate condition =
    if condition.parent_id == conditionToUpdate.parent_id then
        conditionToUpdate

    else
        condition

setValid : Condition -> Bool -> Condition
setValid condition value = 
    { condition | isValid = value }


updateAnswer answerToUpdate answer =
    if getAnswerID answer == getAnswerID answerToUpdate then
        answerToUpdate

    else
        answer


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


getConditionWithParentID : List Condition -> Int -> Condition
getConditionWithParentID list id = 
    case List.head (Tuple.first (List.partition (\e -> e.parent_id == id) list)) of
        Just condition ->
            condition
        Nothing ->
            initCondition


getElementWithText : String -> Questionnaire -> Q_element
getElementWithText string questionnaire =
    case List.head (Tuple.first (List.partition (\e -> getText e == string) questionnaire.elements)) of 
        Just element ->
            element
        Nothing ->
            initQuestion

getAnswerID : Answer -> Int
getAnswerID answer = answer.id


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

getAnswerText : Answer -> String                                           
getAnswerText answer = answer.text


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

getAnswerType : Answer -> String                                            
getAnswerType answer = answer.typ

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


getElementId : Q_element -> Int
getElementId elem = 
    case elem of
        Question a -> a.id
        Note a -> a.id