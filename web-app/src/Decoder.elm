module Decoder exposing (answerDecoder, conditionDecoder, decodeConditions, decodeElements, decodeTitle, decodeId, decodePriority, elementDecoder, noteDecoder, questionDecoder, decodeViewingTime, decodeReminderTimes, decodeEditTime)

{-| Enthält die Decoder für Questionnaire, QElement, Answer (usw.).


# Öffentliche Funktionen

@docs answerDecoder,  conditionDecoder, decodeConditions, decodeElements, decodeTitle, decodeId, decodePriority, elementDecoder, noteDecoder, questionDecoder, decodeViewingTime, decodeReminderTimes, decodeEditTime

-}

import Answer exposing (Answer)
import Condition exposing (Condition)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import QElement exposing (Q_element(..))


{-| Decodiert den Titel des Questionnaires, kann aber auch auf andere Typen angewendet werden.
-}
decodeTitle : String -> String
decodeTitle content =
    case Decode.decodeString (Decode.field "title" Decode.string) content of
        Ok val ->
            val

        Err e ->
            ""
{-| Decodiert die ID des Questionnaires
-}
decodeId : String -> Int 
decodeId content =
    case Decode.decodeString (Decode.field "id" Decode.int) content of
        Ok val ->
            val
        
        Err e ->
            -1

{-| Decodiert die Priorität des Questionnaires
-}           
decodePriority : String -> Int
decodePriority content =    
    case Decode.decodeString (Decode.field "priority" Decode.int) content of
        Ok val ->
            val 
        
        Err e ->
            -1


{-| Decodiert eine Liste von Fragebogenelementen (Fragen, Anmerkunden).
-}
decodeElements : String -> List Q_element
decodeElements content =
    case Decode.decodeString (Decode.at [ "elements" ] (Decode.list elementDecoder)) content of
        Ok elements ->
            elements

        Err e ->
            []

decodeViewingTime : String -> String
decodeViewingTime content =
    case Decode.decodeString (Decode.field "viewingTime" Decode.string) content of
        Ok val ->
            val
        
        Err e ->
            ""

decodeReminderTimes : String -> List String
decodeReminderTimes content =
    case Decode.decodeString (Decode.field "reminderTimes" (Decode.list Decode.string)) content of 
        Ok val ->
            val 
        
        Err e ->
            []

decodeEditTime : String -> String
decodeEditTime content =
    case Decode.decodeString (Decode.field "editTime" Decode.string) content of
        Ok val ->
            val
        
        Err e ->
            ""
{-| Decodiert eine Liste von Bedingungen
-}
decodeConditions : String -> List Condition
decodeConditions content = 
    case Decode.decodeString (Decode.at [ "conditions" ] (Decode.list conditionDecoder)) content of
        Ok conditions ->
            conditions
        
        Err e ->
            []

{-| Decodiert ein einzelnes Fragebogenelement (Frage, Anmerkung).
-}
elementDecoder : Decode.Decoder Q_element
elementDecoder =
    Decode.oneOf [ questionDecoder, noteDecoder ]


{-| Decodiert eine Anmerkung.
-}
noteDecoder : Decode.Decoder Q_element
noteDecoder =
    Decode.map2 QElement.NoteRecord
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        |> Decode.map Note


{-| Decodiert eine Frage.
-}
questionDecoder : Decode.Decoder Q_element
questionDecoder =
    Decode.succeed QElement.QuestionRecord
        |> required "id" Decode.int
        |> required "text" Decode.string
        |> required "answers" (Decode.list answerDecoder)
        |> required "hint" Decode.string
        |> required "questionType" Decode.string
        |> required "questionTime" Decode.string
        |> required "tableSize" Decode.int
        |> required "topText" Decode.string
        |> required "rightText" Decode.string
        |> required "bottomText" Decode.string
        |> required "leftText" Decode.string
        |> Decode.map Question


{-| Decodiert eine Antwort.
-}
answerDecoder : Decode.Decoder Answer
answerDecoder =
    Decode.map3 Answer
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "_type" Decode.string)

conditionDecoder : Decode.Decoder Condition
conditionDecoder = 
    Decode.succeed Condition
        |> required "parent_id" Decode.int
        |> required "child_id" Decode.int
        |> required "answer_id" Decode.int
        |> hardcoded True
