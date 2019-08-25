module Answer exposing (Answer, freeAnswer, getAnswerID, getAnswerText, getAnswerType, getAnswersWithRange, getBipolarAnswers, getUnipolarAnswers, initAnswer, regularAnswer, setPredefinedAnswers, update, updateAnswerList)


type alias Answer =
    { id : Int
    , text : String

    --type can be "free" or "regular"
    , typ : String
    }


initAnswer : Answer
initAnswer =
    { id = 0
    , text = ""

    --type can be "free" or "regular"
    , typ = ""
    }


setPredefinedAnswers : String -> List Answer
setPredefinedAnswers questionType =
    if questionType == "Ja/Nein Frage" then
        [ regularAnswer 0 "Ja", regularAnswer 1 "Nein" ]

    else
        []


regularAnswer : Int -> String -> Answer
regularAnswer int string =
    { id = int
    , text = string
    , typ = "regular"
    }


freeAnswer : Int -> String -> Answer
freeAnswer int string =
    { id = int
    , text = string
    , typ = "free"
    }


getUnipolarAnswers : String -> List Answer
getUnipolarAnswers string =
    case String.toInt string of
        Nothing ->
            []

        Just val ->
            getAnswersWithRange 1 val 0


getBipolarAnswers : String -> List Answer
getBipolarAnswers string =
    case String.toInt string of
        Nothing ->
            []

        Just val ->
            getAnswersWithRange -val val 0


getAnswersWithRange : Int -> Int -> Int -> List Answer
getAnswersWithRange begin end index =
    if begin == end then
        [ regularAnswer index (String.fromInt end) ]

    else
        [ regularAnswer index (String.fromInt begin) ] ++ getAnswersWithRange (begin + 1) end (index + 1)


updateAnswerList : Answer -> List Answer -> List Answer
updateAnswerList answerToUpdate list =
    List.map (update answerToUpdate) list


update : Answer -> Answer -> Answer
update answerToUpdate answer =
    if getAnswerID answer == getAnswerID answerToUpdate then
        answerToUpdate

    else
        answer


getAnswerID : Answer -> Int
getAnswerID answer =
    answer.id


getAnswerText : Answer -> String
getAnswerText answer =
    answer.text


getAnswerType : Answer -> String
getAnswerType answer =
    answer.typ
