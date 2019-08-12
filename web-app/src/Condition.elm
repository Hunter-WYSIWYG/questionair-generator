module Condition exposing (..)

import Answer exposing (Answer)
import QElement exposing (Q_element)

type alias Condition = 
    { parent_id : Int
    , child_id : Int
    , answers : List Answer
    , isValid : Bool }

initCondition : Condition
initCondition = 
    { parent_id = -1
    , child_id = -1
    , answers = []
    , isValid = False
    }


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
    case QElement.getAnswerWithID id newElement of 
        Just newAnswer ->
            { condition | answers = condition.answers ++ [newAnswer]}
        Nothing ->
            condition


removeConditionFromCondList : Condition -> List Condition -> List Condition
removeConditionFromCondList condition list = 
    Tuple.first (List.partition (\c -> c.parent_id /= condition.parent_id) list)


updateCondition : Condition -> Condition -> Condition
updateCondition conditionToUpdate condition =
    if condition.parent_id == conditionToUpdate.parent_id then
        conditionToUpdate

    else
        condition

setValid : Condition -> Bool -> Condition
setValid condition value = 
    { condition | isValid = value }


getConditionWithParentID : List Condition -> Int -> Condition
getConditionWithParentID list id = 
    case List.head (Tuple.first (List.partition (\e -> e.parent_id == id) list)) of
        Just condition ->
            condition
        Nothing ->
            initCondition