module Condition exposing
    ( Condition
    , deleteConditionFrom, deleteConditionWithChild, deleteConditionWithElement, deleteConditionWithParent, getNewConditionID, initCondition, removeConditionFromCondList, setParentChildInCondition, setValid, updateCondition, updateConditionAnswer, updateConditionAnswers, updateConditionID, updateConditionWithAnswer, updateIDsInCondition, validateCondition
    )

{-| Contains the Condition type for conditions.


# Definition

@docs Condition


# Public functions

@docs addAnswerOfQuestionToCondition, deleteAnswerInCondition, deleteCondAnswer, deleteConditionWithChild, deleteConditionWithElement, deleteConditionWithParent, getNewConditionID, initCondition, removeConditionFromCondList, setParentChildInCondition, setValid, updateCondition, updateConditionAnswer, updateConditionAnswers, updateConditionID, updateConditionWithAnswer, updateIDsInCondition

-}

import Answer exposing (Answer)
import QElement exposing (Q_element)


{-| Conditions have a parent\_id and child\_id that refer to a question (child) and the question (parent) which acts as the condition.
It will jump to the question with the child\_id if an answer from the list of answers in the question with the parent\_id is answered.
-}
type alias Condition =
    { parent_id : Int
    , child_id : Int
    , answer_id : Int
    , isValid : Bool
    }


{-| Empty condition for the Input-Condition. Refers to no specific questions and is overwritten with the Input.
-}
initCondition : Condition
initCondition =
    { parent_id = -1
    , child_id = -1
    , answer_id = -1
    , isValid = False
    }


{-| Searches the condition with the old ID from a list and updates its ID when updating the question sequence.
-}
updateIDsInCondition : List Condition -> Int -> Int -> List Condition
updateIDsInCondition list old new =
    List.map (updateConditionID old new) list


{-| updates the QuestionId of the child and parent questions
-}
updateConditionID : Int -> Int -> Condition -> Condition
updateConditionID old new condition =
    { condition
        | child_id = getNewConditionID condition.child_id old new
        , parent_id = getNewConditionID condition.parent_id old new
    }


{-| Searches for the new and the old ID and rewrites if necessary
-}
getNewConditionID : Int -> Int -> Int -> Int
getNewConditionID cond_id old new =
    if cond_id == old then
        new

    else if cond_id == new then
        old

    else
        cond_id


{-| Searches the condition with the old AnswerId from a list and updates its Id when updating the order of questions.
-}
updateConditionAnswers : List Condition -> Int -> Int -> List Condition
updateConditionAnswers list old new =
    List.map (updateConditionWithAnswer old new) list


{-| Updates the AnswerId of each condition
-}
updateConditionWithAnswer : Int -> Int -> Condition -> Condition
updateConditionWithAnswer old new condition = { condition | answer_id =  updateConditionAnswer old new condition.answer_id}


{-| Searches for the new and the old ID and rewrites if necessary
-}
updateConditionAnswer : Int -> Int -> Int -> Int
updateConditionAnswer old new answer_id =
    if answer_id == old then
        new

    else if answer_id == new then
        old

    else
        answer_id


{-| Deletes a condition from a list of conditions that contains the element with the specified ID.
-}
deleteConditionWithElement : List Condition -> Int -> List Condition
deleteConditionWithElement list id =
    deleteConditionWithParent (deleteConditionWithChild list id) id


{-| Deletes a condition from a list of conditions that contains the element with the specified ID as a PARENT\_ID.
-}
deleteConditionWithParent : List Condition -> Int -> List Condition
deleteConditionWithParent list id =
    Tuple.first (List.partition (\e -> e.parent_id /= id) list)


{-| Deletes a condition from a list of conditions that contains the element with the specified ID as CHILD\_ID.
-}
deleteConditionWithChild : List Condition -> Int -> List Condition
deleteConditionWithChild list id =
    Tuple.first (List.partition (\e -> e.child_id /= id) list)


{-| Updates the question IDs in one condition.
-}
setParentChildInCondition : Int -> Int -> Condition -> Condition
setParentChildInCondition parent child condition =
    { condition
        | parent_id = parent
        , child_id = child
        , isValid = True
    }


{-| Removes a condition from the list of conditions.
-}
removeConditionFromCondList : Condition -> List Condition -> List Condition
removeConditionFromCondList condition list =
    Tuple.first (List.partition (\c -> c.parent_id /= condition.parent_id) list)


{-| Replaces a condition in a list of conditions with conditionToUpdate.
-}
updateCondition : Condition -> Condition -> Condition
updateCondition conditionToUpdate condition =
    if condition.parent_id == conditionToUpdate.parent_id then
        conditionToUpdate

    else
        condition


{-| Sets isValid of a condition to the specified value.
-}
setValid : Condition -> Bool -> Condition
setValid condition value =
    { condition | isValid = value }


{-| Deletes a condition from the condition list
-}
deleteConditionFrom : Condition -> List Condition -> List Condition
deleteConditionFrom condition list =
    Tuple.first (List.partition (\e -> e /= condition) list)

{-| Check whether the condition is valid
-}
validateCondition : Condition -> Q_element -> Bool
validateCondition condition q_element =
    let
        id = condition.answer_id
        answers = case q_element of
                        QElement.Note n -> []
                        QElement.Question q -> q.answers
    in
    checkAnswerID answers id

{-| TODO 
-}
checkAnswerID : List Answer -> Int -> Bool
checkAnswerID answers answer_id =
    let
        id =
            case (List.head answers) of
                Just a -> a.id
                Nothing -> -1
    in
        if id == answer_id then True
        else    
            case List.tail answers of
                Just list -> checkAnswerID list answer_id
                Nothing -> False
