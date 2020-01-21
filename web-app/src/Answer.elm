module Answer exposing
    ( Answer
    , getBipolarAnswers, getUnipolarAnswers, initAnswer, getYesNoAnswers, update, getAnswerId, getAnswerText, getAnswerTyp, getDisplayAnswerTyp
    )

{-| Contains the answer type used for questions and conditions.


# Definition

@docs Answer


# Public functions

@docs getBipolarAnswers, getUnipolarAnswers, initAnswer, getYesNoAnswers, update, getAnswerId, getAnswerText, getAnswerTyp, getDisplayAnswerTyp

-}


{-| Represents answers that occur in questions and conditions. Answers consist of a unique ID, a text and a type.
A type can be either 'free' or 'regular'
-}
type alias Answer =
    { id : Int
    , text : String
    , typ : String
    }


{-| An answer without type and text used as input when creating a new question.
The answer will be included in the list of answers if text and type have been adjusted.
-}
initAnswer : Answer
initAnswer =
    { id = 0
    , text = ""
    , typ = ""
    }


{-| Returns the predefined answers for yes / no questions
-}
getYesNoAnswers : String -> List Answer
getYesNoAnswers questionType =
    if questionType == "Ja/Nein Frage" then
        [ regularAnswer 0 "Ja", regularAnswer 1 "Nein" ]

    else
        []


{-| Returns a regular answer with a set ID and text.
-}
regularAnswer : Int -> String -> Answer
regularAnswer int string =
    { id = int
    , text = string
    , typ = "regular"
    }


{-| Returns a free answer (free input) with a defined ID and text.
-}
freeAnswer : Int -> String -> Answer
freeAnswer int string =
    { id = int
    , text = string
    , typ = "free"
    }


{-| Returns a list of answers for unipolar answers ranging from 0 to the specified value.
-}
getUnipolarAnswers : String -> List Answer
getUnipolarAnswers string =
    case String.toInt string of
        Nothing ->
            []

        Just val ->
            getAnswersWithRange 1 val 0


{-| Returns a list of answers for bipolar answers ranging from the negative specified value to the positive value.
-}
getBipolarAnswers : String -> List Answer
getBipolarAnswers string =
    case String.toInt string of
        Nothing ->
            []

        Just val ->
            getAnswersWithRange -val val 0


{-| Returns a list of answers ranging from start to end.
-}
getAnswersWithRange : Int -> Int -> Int -> List Answer
getAnswersWithRange begin end index =
    if begin == end then
        [ regularAnswer index (String.fromInt end) ]

    else
        [ regularAnswer index (String.fromInt begin) ] ++ getAnswersWithRange (begin + 1) end (index + 1)


{-| Updates the specified answer in a list of answers. It searches for the answer with the corresponding ID in the list and replaces it with the specified answer.
-}
updateAnswerList : Answer -> List Answer -> List Answer
updateAnswerList answerToUpdate list =
    List.map (update answerToUpdate) list


{-| Checks if two answers have the same IDs and replaces answer with answerToUpdate.
-}
update : Answer -> Answer -> Answer
update answerToUpdate answer =
    if answer.id == answerToUpdate.id then
        answerToUpdate

    else
        answer

{-| getter for answer id
-}
getAnswerId : Answer -> Int
getAnswerId answer = answer.id

{-| getter for answer text
-}
getAnswerText : Answer -> String
getAnswerText answer = answer.text

{-| getter for answer typ
-}
getAnswerTyp : Answer -> String
getAnswerTyp answer = answer.typ

{- getter for answer type for displaying in german 
-}
getDisplayAnswerTyp : Answer -> String
getDisplayAnswerTyp answer =
    if answer.typ == "regular" then
        "Fester Wert "
    else
        if answer.typ == "free" then
            "Freie Eingabe"
        else 
            ""