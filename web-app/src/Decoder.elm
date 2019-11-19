module Decoder exposing (answerDecoder, decodeElements, decodeTitle, elementDecoder, noteDecoder, questionDecoder)

{-| Contains the decoder for Questionnaire, QElement, Answer (etc.).


# Public functions

@docs answerDecoder, decodeElements, decodeTitle, elementDecoder, noteDecoder, questionDecoder

-}

import Answer exposing (Answer)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import QElement exposing (Q_element(..))


{-| Decodes the title of the questionnaire, but can also be applied to other types.
-}
decodeTitle : String -> String
decodeTitle content =
    case Decode.decodeString (Decode.field "title" Decode.string) content of
        Ok val ->
            val

        Err e ->
            ""


{-| Decodes a list of questionnaire items (questions, annotations).
-}
decodeElements : String -> List Q_element
decodeElements content =
    case Decode.decodeString (Decode.at [ "elements" ] (Decode.list elementDecoder)) content of
        Ok elements ->
            elements

        Err e ->
            []


{-| Decodes a single questionnaire item (question, annotation).
-}
elementDecoder : Decode.Decoder Q_element
elementDecoder =
    Decode.oneOf [ questionDecoder, noteDecoder ]


{-| Decodes an annotation.
-}
noteDecoder : Decode.Decoder Q_element
noteDecoder =
    Decode.map2 QElement.NoteRecord
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        |> Decode.map Note


{-| Decodes a question.
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


{-| Decodes an answer.
-}
answerDecoder : Decode.Decoder Answer
answerDecoder =
    Decode.map3 Answer
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "_type" Decode.string)
