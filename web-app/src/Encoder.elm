module Encoder exposing (encodeQuestionnaire, save)

{-| Enthält die Decoder für Questionnaire, QElement, Answer (usw.).


# Öffentliche Funktionen

@docs encodeQuestionnaire, save

-}

import Answer exposing (Answer)
import Condition exposing (Condition)
import File.Download as Download
import Json.Encode as Encode exposing (encode, object)
import QElement exposing (Q_element(..))
import Questionnaire exposing (Questionnaire)


{-| Encodiert einen Fragebogen als JSON.
-}
encodeQuestionnaire : Questionnaire -> String
encodeQuestionnaire questionnaire =
    encode 4
        (object
            [ ( "id", Encode.int questionnaire.id )
            , ( "priority", Encode.int questionnaire.priority )
            , ( "title", Encode.string questionnaire.title )
            , ( "elements", Encode.list elementEncoder questionnaire.elements )
            , ( "conditions", Encode.list conditionEncoder questionnaire.conditions )
            , ( "viewingTime", Encode.string questionnaire.viewingTime )
            , ( "reminderTimes", Encode.list Encode.string questionnaire.reminderTimes )
            , ( "editTime", Encode.string questionnaire.editTime ) 
            ]
        )


{-| Encodiert ein Fragebogenelement (Frage, Anmerkung).
-}
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
                , ( "questionType", Encode.string record.typ )
                , ( "answers", Encode.list answerEncoder record.answers )
                , ( "questionTime", Encode.string record.questionTime )
                , ( "tableSize", Encode.int record.tableSize )
                , ( "topText", Encode.string record.topText )
                , ( "rightText", Encode.string record.rightText )
                , ( "bottomText", Encode.string record.bottomText )
                , ( "leftText", Encode.string record.leftText )
                ]


{-| Encodiert eine Bedingung.
-}
conditionEncoder : Condition -> Encode.Value
conditionEncoder condition =
    object
        [ ( "parent_id", Encode.int condition.parent_id )
        , ( "child_id", Encode.int condition.child_id )
        , ( "answer_id", Encode.int condition.answer_id )
        ]


{-| Encodiert Antworten.
-}
answerEncoder : Answer -> Encode.Value
answerEncoder answer =
    object
        [ ( "id", Encode.int answer.id )
        , ( "text", Encode.string answer.text )
        , ( "_type", Encode.string answer.typ )
        ]


{-| Ermöglicht das Speichern von erstellten Fragebögen im Dateisystem des Nutzers (Downloadfunktion).
-}
save : Questionnaire -> String -> Cmd msg
save questionnaire export =
    Download.string (questionnaire.title ++ ".json") "application/json" export
