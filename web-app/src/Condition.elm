module Condition exposing
    ( Condition
    , deleteConditionFrom, deleteConditionWithChild, deleteConditionWithElement, deleteConditionWithParent, getConditionWithParentID, getNewConditionID, initCondition, removeConditionFromCondList, setParentChildInCondition, setValid, updateCondition, updateConditionAnswer, updateConditionAnswers, updateConditionID, updateConditionWithAnswer, updateIDsInCondition, validateCondition
    )

{-| Enthält den Typ Condition für Bedingungen.


# Definition

@docs Condition


# Öffentliche Funktionen

@docs addAnswerOfQuestionToCondition, deleteAnswerInCondition, deleteCondAnswer, deleteConditionWithChild, deleteConditionWithElement, deleteConditionWithParent, getConditionWithParentID, getNewConditionID, initCondition, removeConditionFromCondList, setParentChildInCondition, setValid, updateCondition, updateConditionAnswer, updateConditionAnswers, updateConditionID, updateConditionWithAnswer, updateIDsInCondition

-}

import Answer exposing (Answer)
import QElement exposing (Q_element)


{-| Bedingungen haben eine parent\_id und child\_id, die sich auf eine Frage (child) und die Frage (parent) mit der enthaltenen Bedingung beziehen.
Es wird zu der Frage mit der child\_id gesprungen, wenn eine Antwort aus der Liste von Antworten in der Frage mit der parent\_id beantwortet ist.
-}
type alias Condition =
    { parent_id : Int
    , child_id : Int
    , answer_id : Int
    , isValid : Bool
    }


{-| Leere Bedingung für die Input-Condition. Bezieht sich auf keine konkreten Fragen und wird mit dem Input überschrieben.
-}
initCondition : Condition
initCondition =
    { parent_id = -1
    , child_id = -1
    , answer_id = -1
    , isValid = False
    }


{-| Sucht die Condition mit der alten Id aus einer Liste und aktualisiert deren Id bei Aktualisierung der Fragenreihenfolge.
-}
updateIDsInCondition : List Condition -> Int -> Int -> List Condition
updateIDsInCondition list old new =
    List.map (updateConditionID old new) list


{-| updated die FrageId der child und parent Frage 
-}
updateConditionID : Int -> Int -> Condition -> Condition
updateConditionID old new condition =
    { condition
        | child_id = getNewConditionID condition.child_id old new
        , parent_id = getNewConditionID condition.parent_id old new
    }


{-| Suche nach der neuen und der alten Id und wenn nötig umschreiben
-}
getNewConditionID : Int -> Int -> Int -> Int
getNewConditionID cond_id old new =
    if cond_id == old then
        new

    else if cond_id == new then
        old

    else
        cond_id


{-| Sucht die Condition mit der alten AnswerId aus einer Liste und aktualisiert deren Id bei Aktualisierung der Fragenreihenfolge.
-}
updateConditionAnswers : List Condition -> Int -> Int -> List Condition
updateConditionAnswers list old new =
    List.map (updateConditionWithAnswer old new) list


{-| update der AnswerId jeder Condition
-}
updateConditionWithAnswer : Int -> Int -> Condition -> Condition
updateConditionWithAnswer old new condition = { condition | answer_id =  updateConditionAnswer old new condition.answer_id}


{-| Suche nach der neuen und der alten Id und wenn nötig umschreiben
-}
updateConditionAnswer : Int -> Int -> Int -> Int
updateConditionAnswer old new answer_id =
    if answer_id == old then
        new

    else if answer_id == new then
        old

    else
        answer_id


{-| Löscht eine Condition aus einer Liste von Conditions, die das Element mit der angegebenen ID enthält.
-}
deleteConditionWithElement : List Condition -> Int -> List Condition
deleteConditionWithElement list id =
    deleteConditionWithParent (deleteConditionWithChild list id) id


{-| Löscht eine Condition aus einer Liste von Conditions, die das Element mit der angegebenen ID als PARENT\_ID enthält.
-}
deleteConditionWithParent : List Condition -> Int -> List Condition
deleteConditionWithParent list id =
    Tuple.first (List.partition (\e -> e.parent_id /= id) list)


{-| Löscht eine Condition aus einer Liste von Conditions, die das Element mit der angegebenen ID als CHILD\_ID enthält.
-}
deleteConditionWithChild : List Condition -> Int -> List Condition
deleteConditionWithChild list id =
    Tuple.first (List.partition (\e -> e.child_id /= id) list)


{-| Aktualisiert die Fragen-IDs in einer Condition.
-}
setParentChildInCondition : Int -> Int -> Condition -> Condition
setParentChildInCondition parent child condition =
    { condition
        | parent_id = parent
        , child_id = child
        , isValid = True
    }


{-| Entfernt eine Condition aus der Liste von Conditions.
-}
removeConditionFromCondList : Condition -> List Condition -> List Condition
removeConditionFromCondList condition list =
    Tuple.first (List.partition (\c -> c.parent_id /= condition.parent_id) list)


{-| Ersetzt eine Condition in einer Liste von Conditions durch conditionToUpdate.
-}
updateCondition : Condition -> Condition -> Condition
updateCondition conditionToUpdate condition =
    if condition.parent_id == conditionToUpdate.parent_id then
        conditionToUpdate

    else
        condition


{-| Setzt isValid einer Condition auf den angegebenen Wert.
-}
setValid : Condition -> Bool -> Condition
setValid condition value =
    { condition | isValid = value }


{-| Gibt aus einer Liste von Conditions die Condition zurück, die als parent\_id die angegebene ID hat.
-}
getConditionWithParentID : List Condition -> Int -> Condition
getConditionWithParentID list id =
    case List.head (Tuple.first (List.partition (\e -> e.parent_id == id) list)) of
        Just condition ->
            condition

        Nothing ->
            initCondition

{-| Löscht eine Condition aus der Condition Liste
-}
deleteConditionFrom : Condition -> List Condition -> List Condition
deleteConditionFrom condition list =
    Tuple.first (List.partition (\e -> e /= condition) list)

validateCondition : Condition -> List Q_element -> Condition
validateCondition newCondition q_elements =
    if  (newCondition.parent_id /= -1)
        && (checkParentAndAnswerID q_elements newCondition.parent_id newCondition.answer_id)
        && (checkChildID q_elements newCondition.child_id)
    then { newCondition | isValid = True }
    else { newCondition | isValid = False }

checkParentAndAnswerID : List Q_element -> Int -> Int -> Bool
checkParentAndAnswerID q_elements parent_id answer_id =
    let
        pid =
            case (List.head q_elements) of
                Just (QElement.Note n) -> n.id
                Just (QElement.Question q) -> q.id
                Nothing -> -1
    in
    if not (pid == parent_id)
    then    case List.tail q_elements of
                Just list -> checkParentAndAnswerID list parent_id answer_id
                Nothing -> False
    else    case (List.head q_elements) of
                Nothing -> True
                Just (QElement.Note n) -> True
                Just (QElement.Question q) -> checkAnswerID q.answers answer_id

checkChildID : List Q_element -> Int -> Bool
checkChildID q_elements child_id =
    let
        id =
            case (List.head q_elements) of
                Just (QElement.Note n) -> n.id
                Just (QElement.Question q) -> q.id
                Nothing -> -1
    in
    if not (id == child_id)
    then    case List.tail q_elements of
                Just list -> checkChildID list child_id
                Nothing -> False
    else True

checkAnswerID : List Answer -> Int -> Bool
checkAnswerID answers answer_id =
    let
        id =
            case (List.head answers) of
                Just a -> a.id
                Nothing -> -1
    in
    if not (id == answer_id)
    then    case List.tail answers of
                Just list -> checkAnswerID list answer_id
                Nothing -> False
    else True
