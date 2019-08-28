module Encoder exposing (encodeQuestionnaire, save)

import Answer exposing (Answer)
import Condition exposing (Condition)
import File.Download as Download
import Json.Encode as Encode exposing (encode, object)
import QElement exposing (Q_element(..))
import Questionnaire exposing (Questionnaire)



--encodes questionnaire as a json


encodeQuestionnaire : Questionnaire -> String
encodeQuestionnaire questionnaire =
    encode 4
        (object
            [ ( "title", Encode.string questionnaire.title )
            , ( "elements", Encode.list elementEncoder questionnaire.elements )
            , ( "conditions", Encode.list conditionEncoder questionnaire.conditions )
            ]
        )



--encodes Q_element


elementEncoder : Q_element -> Encode.Value
elementEncoder element =
    case element of
        Note record ->
            object
                [ ( "_type", Encode.string "Note" )
                , ( "id", Encode.int record.id )
                , ( "text", Encode.string record.text )
                ]

        Question record ->
            object
                [ ( "_type", Encode.string "Question" )
                , ( "id", Encode.int record.id )
                , ( "text", Encode.string record.text )
                , ( "hint", Encode.string record.hint )
                , ( "question_type", Encode.string record.typ )
                , ( "answers", Encode.list answerEncoder record.answers )
                , ( "question_time", Encode.string record.questionTime )
                ]



--encodes conditions


conditionEncoder : Condition -> Encode.Value
conditionEncoder condition =
    object
        [ ( "parent_id", Encode.int condition.parent_id )
        , ( "child_id", Encode.int condition.child_id )
        , ( "answers", Encode.list answerEncoder condition.answers )
        ]



--Save to file system


save : Questionnaire -> String -> Cmd msg
save questionnaire export =
    Download.string (questionnaire.title ++ ".json") "application/json" export



--encodes answers


answerEncoder : Answer -> Encode.Value
answerEncoder answer =
    object
        [ ( "id", Encode.int answer.id )
        , ( "text", Encode.string answer.text )
        , ( "_type", Encode.string answer.typ )
        ]