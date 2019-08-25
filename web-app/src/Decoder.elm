module Decoder exposing (answerDecoder, decodeElements, decodeTitle, elementDecoder, noteDecoder, questionDecoder)

import Answer exposing (Answer)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import QElement exposing (Q_element(..))



--DECODER
-- extracts the title of the questionnaire


decodeTitle : String -> String
decodeTitle content =
    case Decode.decodeString (Decode.field "title" Decode.string) content of
        Ok val ->
            val

        Err e ->
            ""



--extracts the elements (notes, questions) of the questionnaire


decodeElements : String -> List Q_element
decodeElements content =
    case Decode.decodeString (Decode.at [ "elements" ] (Decode.list elementDecoder)) content of
        Ok elements ->
            elements

        Err e ->
            []



--decodes the elements either to a note, or to a question


elementDecoder : Decode.Decoder Q_element
elementDecoder =
    Decode.oneOf [ questionDecoder, noteDecoder ]



--decodes a note


noteDecoder : Decode.Decoder Q_element
noteDecoder =
    Decode.map2 QElement.NoteRecord
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        |> Decode.map Note



--decodes a question


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



--decodes a answer


answerDecoder : Decode.Decoder Answer
answerDecoder =
    Decode.map3 Answer
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "_type" Decode.string)
