module QElement exposing
    ( Q_element(..), NoteRecord, QuestionRecord
    , deleteAnswerFromItem, deleteItemFrom, getAnswerWithID, getAntworten, getElementId, getElementText, getID, getQuestionHinweis, getQuestionTyp, getText, initQuestion, putAnswerDown, putAnswerUp, putElementDown, putElementUp, setNewID, updateAnsID, updateElement, updateElementList, updateID
    )

{-| Enthält den Typ für die Elemente von Fragebögen (Fragen, Anmerkungen) und ein Anfangszustand für das "Input-Element" (newElement).


# Definition

@docs Q_element, NoteRecord, QuestionRecord


# Öffentliche Funktionen

@docs deleteAnswerFromItem, deleteItemFrom, getAnswerWithID, getAntworten, getElementId, getElementText, getID, getQuestionHinweis, getQuestionTyp, getText, initQuestion, putAnswerDown, putAnswerUp, putElementDown, putElementUp, setNewID, updateAnsID, updateElement, updateElementList, updateID

-}

import Answer exposing (Answer)
import List.Extra as LExtra


{-| Element eines Fragebogens (Frage, Anmerkung)
-}
type Q_element
    = Note NoteRecord
    | Question QuestionRecord


{-| Record einer Anmerkung mit ID und Text der Anmerkung.
-}
type alias NoteRecord =
    { id : Int
    , text : String
    }


{-| Record einer Frage mit ID, Text, Liste von Antworten, Hinweis, Fragetyp und Fragenzeit.
-}
type alias QuestionRecord =
    { id : Int
    , text : String
    , answers : List Answer
    , hint : String
    , typ : String
    , questionTime : String
    }


{-| Anfangszustand einer Frage für die "Inputfrage" (newElement).
-}
initQuestion : Q_element
initQuestion =
    Question
        { id = 0
        , text = "Beispielfrage"
        , answers = []
        , hint = ""
        , typ = ""
        , questionTime = ""
        }


{-| Hilfsfunktion für das Erhöhen der ID einer Frage. Die Frage wird dann in der Tabelle von Fragen um eine Position nach oben verschoben.
-}
putElementUp : List Q_element -> Q_element -> List Q_element
putElementUp list element =
    LExtra.swapAt (getID element) (getID element - 1) (List.map (updateID (getID element) (getID element - 1)) list)


{-| Hilfsfunktion für das Verringern der ID einer Frage. Die Frage wird dann in der Tabelle von Fragen um eine Position nach unten verschoben.
-}
putElementDown : List Q_element -> Q_element -> List Q_element
putElementDown list element =
    LExtra.swapAt (getID element) (getID element + 1) (List.map (updateID (getID element) (getID element + 1)) list)


{-| Hilfsfunktion für das Erhöhen der ID einer Antwort. Die Frage wird dann in der Tabelle von Antworten einer Frage um eine Position nach oben verschoben.
-}
putAnswerUp : Q_element -> Answer -> Q_element
putAnswerUp newElement answer =
    case newElement of
        Note record ->
            Note record

        Question record ->
            Question { record | answers = LExtra.swapAt answer.id (answer.id - 1) (List.map (updateAnsID answer.id (answer.id - 1)) record.answers) }


{-| Hilfsfunktion für das Verringern der ID einer Antwort. Die Frage wird dann in der Tabelle von Antworten einer Frage um eine Position nach unten verschoben.
-}
putAnswerDown : Q_element -> Answer -> Q_element
putAnswerDown newElement answer =
    case newElement of
        Note record ->
            Note record

        Question record ->
            Question { record | answers = LExtra.swapAt answer.id (answer.id + 1) (List.map (updateAnsID answer.id (answer.id + 1)) record.answers) }


{-| Setzt eine neue ID eines Fragebogenelements.
-}
setNewID : Q_element -> Int -> Q_element
setNewID element new =
    case element of
        Note record ->
            Note { record | id = new }

        Question record ->
            Question { record | id = new }


{-| Vertauscht die IDs zweier Elemente mit den IDs "old" und "new".
Hat das Fragebogenelement die ID "old", wird die ID auf "new" gesetzt. Ist die ID gleich "new", wird die ID auf "old" gesetzt.
-}
updateID : Int -> Int -> Q_element -> Q_element
updateID old new element =
    if getID element == old then
        setNewID element new

    else if getID element == new then
        setNewID element old

    else
        element


{-| Vertauscht die IDs zweier Antowrten mit den IDs "old" und "new".
Hat das Antwort die ID "old", wird die ID auf "new" gesetzt. Ist die ID gleich "new", wird die ID auf "old" gesetzt.
-}
updateAnsID : Int -> Int -> Answer -> Answer
updateAnsID old new answer =
    if answer.id == old then
        { answer | id = new }

    else if answer.id == new then
        { answer | id = old }

    else
        answer


{-| Findet die Antwort mit der angegebenen ID innerhalb einer Frage.
-}
getAnswerWithID : Int -> Q_element -> Maybe Answer
getAnswerWithID id newElement =
    case newElement of
        Question record ->
            List.head (Tuple.first (List.partition (\e -> e.id == id) record.answers))

        Note record ->
            Nothing


{-| Gibt die Antworten einer Frage aus.
-}
getAntworten : Q_element -> List Answer
getAntworten element =
    case element of
        Question record ->
            record.answers

        Note record ->
            []


{-| Aktualisiert das angegebene Element in einer Liste von Elementen.
Dabei wird eine Frage mit der ID von elementToUpdate in der Liste list gesucht und durch elementToUpdate ersetzt.
-}
updateElementList : Q_element -> List Q_element -> List Q_element
updateElementList elementToUpdate list =
    List.map (updateElement elementToUpdate) list


{-| Ersetzt das Element element durch elementToUpdate, wenn die IDs beieder Fragebogenelemente übereinstimmen.
-}
updateElement : Q_element -> Q_element -> Q_element
updateElement elementToUpdate element =
    if getID element == getID elementToUpdate then
        elementToUpdate

    else
        element


{-| TODO: WIRKLICH NÖTOG?
Gibt die ID eines Fragebogenelements aus.
-}
getID : Q_element -> Int
getID element =
    case element of
        Question record ->
            record.id

        Note record ->
            record.id


{-| TODO: WIRKLICH NÖTOG?
Gibt den Text eines Fragebogenelements aus.
-}
getText : Q_element -> String
getText element =
    case element of
        Question record ->
            record.text

        Note record ->
            record.text


{-| Löscht das Fragebogenelement element in der Liste list.
Dabei wird das Element in der Liste gesucht, dass die gleiche ID wie element hat.
-}
deleteItemFrom : Q_element -> List Q_element -> List Q_element
deleteItemFrom element list =
    Tuple.first (List.partition (\e -> e /= element) list)


{-| Löscht die angegebene Antwort answer von einer Frage element.
Dabei wird die Antwort in der Liste gesucht, dass die gleiche ID wie answer hat.
-}
deleteAnswerFromItem : Answer -> Q_element -> Q_element
deleteAnswerFromItem answer element =
    case element of
        Question record ->
            Question { record | answers = Tuple.first (List.partition (\e -> e /= answer) record.answers) }

        Note record ->
            Note record


{-| TODO: ENFERNEN! DUPLIZIERT getText
-}
getElementText : Q_element -> String
getElementText element =
    case element of
        Question record ->
            record.text

        Note record ->
            record.text


{-| Gibt den Hinweis einer Frage aus.
-}
getQuestionHinweis : Q_element -> String
getQuestionHinweis element =
    case element of
        Question record ->
            record.hint

        Note record ->
            "None"


{-| Gibt den Typ einer Frage aus
-}
getQuestionTyp : Q_element -> String
getQuestionTyp element =
    case element of
        Question record ->
            record.typ

        Note record ->
            "None"


{-| TODO: ENFERNEN! DUPLIZIERT getID
-}
getElementId : Q_element -> Int
getElementId elem =
    case elem of
        Question a ->
            a.id

        Note a ->
            a.id
