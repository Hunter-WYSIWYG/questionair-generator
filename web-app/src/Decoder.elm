module Decoder exposing (answerDecoder, decodeElements, decodeTitle, elementDecoder, noteDecoder, questionDecoder)

{-| Enthält die Decoder für Questionnaire, QElement, Answer (usw.).


# Öffentliche Funktionen

@docs answerDecoder, decodeElements, decodeTitle, elementDecoder, noteDecoder, questionDecoder

-}

import Answer exposing (Answer)
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


{-| Decodiert eine Liste von Fragebogenelementen (Fragen, Anmerkunden).
-}
decodeElements : String -> List Q_element
decodeElements content =
    case Decode.decodeString (Decode.at [ "elements" ] (Decode.list elementDecoder)) content of
        Ok elements ->
            elements

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
        |> required "question_type" Decode.string
        |> required "question_time" Decode.string
        |> Decode.map Question


{-| Decodiert eine Antwort.
-}
answerDecoder : Decode.Decoder Answer
answerDecoder =
    Decode.map3 Answer
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "_type" Decode.string)
