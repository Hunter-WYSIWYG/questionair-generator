module Condition exposing
    ( Condition
    , addAnswerOfQuestionToCondition, deleteAnswerInCondition, deleteCondAnswer, deleteConditionWithChild, deleteConditionWithElement, deleteConditionWithParent, getConditionWithParentID, getNewConditionID, initCondition, removeConditionFromCondList, setParentChildInCondition, setValid, updateCondition, updateConditionAnswer, updateConditionAnswers, updateConditionID, updateConditionWithAnswer, updateIDsInCondition
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
    , answers : List Answer
    , isValid : Bool
    }


{-| Leere Bedingung für die Input-Condition. Bezieht sich auf keine konkreten Fragen und wird mit dem Input überschrieben.
-}
initCondition : Condition
initCondition =
    { parent_id = -1
    , child_id = -1
    , answers = []
    , isValid = False
    }


{-| Sucht die Condition mit der alten Id aus einer Liste und aktualisiert deren Id bei Aktualisierung der Fragenreihenfolge.
-}
updateIDsInCondition : List Condition -> Int -> Int -> List Condition
updateIDsInCondition list old new =
    List.map (updateConditionID old new) list


{-| TODO
-}
updateConditionID : Int -> Int -> Condition -> Condition
updateConditionID old new condition =
    { condition
        | child_id = getNewConditionID condition.child_id old new
        , parent_id = getNewConditionID condition.parent_id old new
    }


{-| TODO
-}
getNewConditionID : Int -> Int -> Int -> Int
getNewConditionID cond_id old new =
    if cond_id == old then
        new

    else if cond_id == new then
        old

    else
        cond_id


{-| TODO
-}
updateConditionAnswers : List Condition -> Int -> Int -> List Condition
updateConditionAnswers list old new =
    List.map (updateConditionWithAnswer old new) list


{-| TODO
-}
updateConditionWithAnswer : Int -> Int -> Condition -> Condition
updateConditionWithAnswer old new condition =
    { condition | answers = List.map (updateConditionAnswer old new) condition.answers }


{-| TODO
-}
updateConditionAnswer : Int -> Int -> Answer -> Answer
updateConditionAnswer old new answer =
    if answer.id == old then
        { answer | id = new }

    else if answer.id == new then
        { answer | id = old }

    else
        answer


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


{-| TODO
-}
deleteAnswerInCondition : Int -> Condition -> Condition
deleteAnswerInCondition id condition =
    { condition | answers = deleteCondAnswer condition.answers id }


{-| TODO
-}
deleteCondAnswer : List Answer -> Int -> List Answer
deleteCondAnswer list id =
    Tuple.first (List.partition (\answer -> answer.id /= id) list)


{-| Aktualisiert die Fragen-IDs in einer Condition.
-}
setParentChildInCondition : Int -> Int -> Condition -> Condition
setParentChildInCondition parent child condition =
    { condition
        | parent_id = parent
        , child_id = child
        , isValid = True
    }


{-| Sucht die Antwort mit der Angegebenen ID aus der Frage newElement und fügt diese zur Liste von Antworten der Condition hinzu.
-}
addAnswerOfQuestionToCondition : Int -> Q_element -> Condition -> Condition
addAnswerOfQuestionToCondition id newElement condition =
    case QElement.getAnswerWithID id newElement of
        Just newAnswer ->
            { condition | answers = condition.answers ++ [ newAnswer ] }

        Nothing ->
            condition


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

deleteCondition: Condition -> List Condition -> List Condition
deleteCondition condition list =
    Tuple.first (List.partition (\e -> e /= condition) list)
