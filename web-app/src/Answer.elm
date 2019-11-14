module Answer exposing
    ( Answer
    , getBipolarAnswers, getUnipolarAnswers, initAnswer, getYesNoAnswers, update, getAnswerId, getAnswerText
    )

{-| Enthält den Typ Answer für Antworten, der für Questions und Conditions verwendet wird.


# Definition

@docs Answer


# Öffentliche Funktionen

@docs getBipolarAnswers, getUnipolarAnswers, initAnswer, getYesNoAnswers, update

-}


{-| Repäsentiert Antworten, die in Fragen und Bedingungen vorkommen. Antworten bestehen aus einer eindeutigen ID, einem Text und einem Typ.
Ein Typ kann entweder 'free' oder 'regular' sein
-}
type alias Answer =
    { id : Int
    , text : String
    , typ : String
    }


{-| Eine Antwort ohne Typ und Text, die als Input bspw. bei Erzeugung einer neuen Frage verwendet wird.
Die Antwort wird in die Liste der Antworten übernommen, wenn Text und Typ angepasst wurden.
-}
initAnswer : Answer
initAnswer =
    { id = 0
    , text = ""
    , typ = ""
    }


{-| Gibt die vordefinierten Antworten für Ja/Nein-Fragen zurück
-}
getYesNoAnswers : String -> List Answer
getYesNoAnswers questionType =
    if questionType == "Ja/Nein Frage" then
        [ regularAnswer 0 "Ja", regularAnswer 1 "Nein" ]

    else
        []


{-| Gibt eine reguläre Antwort mit festgelegter ID und Text zurück.
-}
regularAnswer : Int -> String -> Answer
regularAnswer int string =
    { id = int
    , text = string
    , typ = "regular"
    }


{-| Gibt eine freie Antwort (freie Eingabe) mit festgelegter ID und Text zurück.
-}
freeAnswer : Int -> String -> Answer
freeAnswer int string =
    { id = int
    , text = string
    , typ = "free"
    }


{-| Gibt eine Liste von Antworten für unipolare Antworten im Bereich von 0 bis zum angegebenen Wert zurück.
-}
getUnipolarAnswers : String -> List Answer
getUnipolarAnswers string =
    case String.toInt string of
        Nothing ->
            []

        Just val ->
            getAnswersWithRange 1 val 0


{-| Gibt eine Liste von Antworten für bipolare Antworten im Bereich vom negativen angegebenen Wert bis zum positiven Wert zurück.
-}
getBipolarAnswers : String -> List Answer
getBipolarAnswers string =
    case String.toInt string of
        Nothing ->
            []

        Just val ->
            getAnswersWithRange -val val 0


{-| Gibt eine Liste von Antworten im Breich von begin bis end zurück.
-}
getAnswersWithRange : Int -> Int -> Int -> List Answer
getAnswersWithRange begin end index =
    if begin == end then
        [ regularAnswer index (String.fromInt end) ]

    else
        [ regularAnswer index (String.fromInt begin) ] ++ getAnswersWithRange (begin + 1) end (index + 1)


{-| Aktualisiert die angegebene Antwort in einer Liste von Antworten. Es wird die Antwort mit der entsprechenden ID in der Liste gesucht und durch die angegebene Antwort ersetzt.
-}
updateAnswerList : Answer -> List Answer -> List Answer
updateAnswerList answerToUpdate list =
    List.map (update answerToUpdate) list


{-| Überprüft ob zwei Antworten die gleichen IDs haben und ersetzt answer durch answerToUpdate.
-}
update : Answer -> Answer -> Answer
update answerToUpdate answer =
    if answer.id == answerToUpdate.id then
        answerToUpdate

    else
        answer

getAnswerId : Answer -> Int
getAnswerId answer = answer.id

getAnswerText : Answer -> String
getAnswerText answer = answer.text
 