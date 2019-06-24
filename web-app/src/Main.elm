module Main exposing (..)

import Browser
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Html exposing (Html, a, br, button, div, footer, form, h1, header, i, input, label, nav, option, p, section, select, table, tbody, thead, td, text, th, tr)
import Html.Attributes exposing (class, href, id, maxlength, minlength, multiple, name, placeholder, style, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode exposing (encode, object)
import List exposing (append)
import List.Extra exposing (swapAt, updateAt)
import Task


main =
    Browser.element
        { init = initQuestionnaire
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--types


type
    Msg
    --Changing Input
    = ChangeQuestionnaireTitle String
    | ChangeEditTime String
    | ChangeViewingTimeBegin String
    | ChangeViewingTimeEnd String
    | ChangeQuestionOrNoteText String
    | ChangeAnswerText String                       
    | ChangeQuestionNote String
    | ChangeQuestionType String
    | ChangeAnswerType String     
    | ChangeQuestionNewAnswer Answer              
    --Modals
    | ViewOrClose ModalType
    --Creates Condition
    | AddCondition String
    | AddConditionAnswer
    | AddAnswerToNewCondition String
    --Save input to questionnaire
    | SetNote
    | SetQuestion
    | SetAnswer                       
    | SetPolarAnswers String
    --Edit existing elements or answers
    | EditQuestion Q_element
    | EditNote Q_element
    | EditAnswer Answer
    | EditQuestionnaire
    --Change order of elements
    | PutUpEl Q_element
    | PutDownEl Q_element
    | PutUpAns Answer
    | PutDownAns Answer
    --Delete existing elements or answers
    | DeleteItem Q_element
    | DeleteAnswer Answer
    --Validation of times
    | Submit
    --Everything releated to upload
    | LeaveOrEnterUpload
    | EnterUpload
    | JsonRequested
    | JsonSelected File
    | JsonLoaded String
    --Everything releated to download
    | DownloadQuestionnaire


type ModalType
    = ViewingTimeModal
    | EditTimeModal
    | NewNoteModal
    | QuestionModal
    | TitleModal
    | AnswerModal


type alias Questionnaire =
    { title : String
    , elements : List Q_element
    , conditions : List Condition
    , newCondition : Condition
    , newAnswerID_Condition : String

    --times
    , viewingTimeBegin : String
    , viewingTimeEnd : String
    , editTime : String

    --modals
    , showTitleModal : Bool
    , showEditTimeModal : Bool
    , showViewingTimeModal : Bool
    , showNewNoteModal : Bool
    , showNewQuestionModal : Bool
    , showNewAnswerModal : Bool

    --newInputs
    , validationResult : ValidationResult
    , inputEditTime : String
    , inputViewingTimeBegin : String
    , inputViewingTimeEnd : String
    , newElement : Q_element
    , newAnswer : Answer

    --editMode for EditQuestion and EditNote
    , editMode : Bool

    --upload determines if the users wants to upload a questionnaire
    --if upload is false show UI to create new questionnaire
    , upload : Bool

    -- a page to edit Questionnaires
    , editQuestionnaire : Bool

    --Debug 
    , tmp : String 
    }


type Q_element
    = Note NoteRecord
    | Question QuestionRecord

type alias Condition = 
    { parent_id : Int
    , child_id : Int
    , answers : List Answer }

type alias NoteRecord =
    { id : Int
    , text : String
    }


type alias QuestionRecord =
    { id : Int
    , text : String
    , answers : List Answer
    , hint : String
    , typ : String
    }


type alias Answer =
    { id : Int
    , text : String

    --type can be "free" or "regular"
    , typ : String
    }


type ValidationResult
    = NotDone
    | Error String
    | ValidationOK


-- SUBSCRIPTIONS


subscriptions : Questionnaire -> Sub Msg
subscriptions model =
    Sub.none


--Init


initQuestionnaire : () -> ( Questionnaire, Cmd Msg )
initQuestionnaire _ =
    ({ title = "Titel eingeben"
    , elements = []
    , conditions = []
    , newCondition = initCondition
    , newAnswerID_Condition = ""

    --times
    , viewingTimeBegin = ""
    , viewingTimeEnd = ""
    , editTime = ""

    --modals
    , showTitleModal = False
    , showViewingTimeModal = False
    , showEditTimeModal = False
    , showNewNoteModal = False
    , showNewQuestionModal = False
    , showNewAnswerModal = False

    --new inputs
    , validationResult = NotDone
    , inputViewingTimeBegin = ""
    , inputViewingTimeEnd = ""
    , inputEditTime = ""
    , newElement = initQuestion
    , newAnswer = initAnswer

    --editMode
    , editMode = False
    , editQuestionnaire = True
    , upload = False
    , tmp = ""
    }
    , Cmd.none)


initQuestion : Q_element
initQuestion =
    Question
        { id = 0
        , text = "Beispielfrage"
        , answers = []
        , hint = ""
        , typ = ""
        }

initAnswer : Answer
initAnswer =
    { id = 0
    , text = ""
    --type can be "free" or "regular"
    , typ = ""
    }

initCondition : Condition
initCondition = 
    { parent_id = -1
    , child_id = -1
    , answers = []
    }

--Update logic


update : Msg -> Questionnaire -> ( Questionnaire, Cmd Msg )
update msg questionnaire =
    case msg of
        --changing properties of notes or questions or answers
        ChangeQuestionnaireTitle newTitle ->
            ( { questionnaire | title = newTitle }, Cmd.none )

        ChangeEditTime newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputEditTime = newTime
                    }
            in
            ( { changedQuestionnaire
                | validationResult = validate changedQuestionnaire
              }
            , Cmd.none
            )

        ChangeViewingTimeBegin newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputViewingTimeBegin = newTime
                    }
            in
            ( { changedQuestionnaire
                | validationResult = validate changedQuestionnaire
              }
            , Cmd.none
            )

        ChangeViewingTimeEnd newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputViewingTimeEnd = newTime
                    }
            in
            ( { changedQuestionnaire
                | validationResult = validate changedQuestionnaire
              }
            , Cmd.none
            )

        ChangeQuestionOrNoteText string ->
            let
                changedRecord rec =
                    { rec | text = string }
            in
            case questionnaire.newElement of
                Question record ->
                    ( { questionnaire | newElement = Question (changedRecord record) }, Cmd.none )

                Note record ->
                    ( { questionnaire | newElement = Note (changedRecord record) }, Cmd.none )

        ChangeQuestionNewAnswer newAnswer ->
            case questionnaire.newElement of
                Question record ->
                    ( { questionnaire
                        | newElement =
                            Question
                                { record | answers = record.answers ++ [ newAnswer ] }
                      }
                    , Cmd.none
                    )

                Note record ->
                    ( questionnaire, Cmd.none )

        ChangeQuestionNote string ->
            case questionnaire.newElement of
                Question record ->
                    ( { questionnaire
                        | newElement =
                            Question
                                { record | hint = string }
                      }
                    , Cmd.none
                    )

                Note record ->
                    ( questionnaire, Cmd.none )

        ChangeQuestionType string ->
            case questionnaire.newElement of
                Question record ->
                    ( { questionnaire
                        | newElement =
                            Question
                                { record | typ = string, answers = setPredefinedAnswers string }
                      }
                    , Cmd.none
                    )

                Note record ->
                    ( questionnaire, Cmd.none )

        ChangeAnswerText string ->
            ({ questionnaire | newAnswer = Answer questionnaire.newAnswer.id string questionnaire.newAnswer.typ }, Cmd.none)     

        ChangeAnswerType string ->
            ({ questionnaire
                | newAnswer =
                    Answer questionnaire.newAnswer.id questionnaire.newAnswer.text string
            }, Cmd.none)

        --open or close modals
        ViewOrClose modalType ->
            case modalType of
                TitleModal ->
                    ( { questionnaire | showTitleModal = not questionnaire.showTitleModal }, Cmd.none )

                ViewingTimeModal ->
                    ( { questionnaire | showViewingTimeModal = not questionnaire.showViewingTimeModal }, Cmd.none )

                EditTimeModal ->
                    ( { questionnaire | showEditTimeModal = not questionnaire.showEditTimeModal }, Cmd.none )

                NewNoteModal ->
                    let
                        changedQuestionnaire =
                            { questionnaire | showNewNoteModal = not questionnaire.showNewNoteModal }
                    in
                    if changedQuestionnaire.showNewNoteModal == True then
                        ( { changedQuestionnaire
                            | newElement =
                                Note
                                    { id = List.length questionnaire.elements
                                    , text = ""
                                    }
                          }
                        , Cmd.none
                        )

                    else
                        ( changedQuestionnaire, Cmd.none )

                QuestionModal ->
                    let
                        changedQuestionnaire =
                            { questionnaire | showNewQuestionModal = not questionnaire.showNewQuestionModal }
                    in
                    if changedQuestionnaire.showNewQuestionModal == True then
                        ( { changedQuestionnaire
                            | newElement =
                                Question
                                    { id = List.length questionnaire.elements
                                    , text = ""
                                    , answers = []
                                    , hint = ""
                                    , typ = ""
                                    }
                          }
                        , Cmd.none
                        )

                    else
                        ( changedQuestionnaire, Cmd.none )

                AnswerModal ->
                    let
                        changedQuestionnaire =
                            { questionnaire | showNewAnswerModal = not questionnaire.showNewAnswerModal }
                    in
                    if changedQuestionnaire.showNewAnswerModal == True then
                        ({ changedQuestionnaire
                            | newAnswer =
                                    { id = (List.length (getAntworten questionnaire.newElement))
                                    , text = ""
                                    --type can be "free" or "regular"
                                    , typ = ""
                                    }
                        }, Cmd.none)

                    else
                        (changedQuestionnaire, Cmd.none)

        --Add Condition
        AddCondition string ->
            let 
                parent = getID questionnaire.newElement
                child = getID (getElementWithText string questionnaire)
            in 
                if string == "Keine" 
                then    ({ questionnaire 
                            | newCondition = setParentChildInCondition -1 -1 questionnaire.newCondition
                        }, Cmd.none)
                else    ({ questionnaire 
                            | newCondition = setParentChildInCondition parent child questionnaire.newCondition
                        }, Cmd.none)

        AddConditionAnswer ->
            case String.toInt (questionnaire.newAnswerID_Condition) of
                Nothing ->
                    (questionnaire, Cmd.none)
                Just id ->
                    ({ questionnaire 
                        | newCondition = addAnswerOfQuestionToCondition id questionnaire.newElement questionnaire.newCondition}
                    , Cmd.none)

        AddAnswerToNewCondition string ->
            ({ questionnaire | newAnswerID_Condition = string }, Cmd.none)

        --Save input to questionnaire
        SetPolarAnswers string ->
            case questionnaire.newElement of
                Question record ->
                    if record.typ == "Skaliert unipolar" then
                        ( { questionnaire | newElement = Question { record | answers = getUnipolarAnswers string } }, Cmd.none )

                    else
                        ( { questionnaire | newElement = Question { record | answers = getBipolarAnswers string } }, Cmd.none )

                Note record ->
                    ( questionnaire, Cmd.none )

        SetNote ->
            if questionnaire.editMode == False then
                ( { questionnaire
                    | elements = append questionnaire.elements [ questionnaire.newElement ]
                    , showNewNoteModal = False
                  }
                , Cmd.none
                )

            else
                ( { questionnaire
                    | elements = List.map (\e -> updateElement questionnaire.newElement e) questionnaire.elements
                    , showNewNoteModal = False
                    , editMode = False
                  }
                , Cmd.none
                )

        SetQuestion ->
            let 
                checkConditionAndAdd condition qn = 
                    if (isConditionValid condition) then 
                    { qn | conditions = append qn.conditions [condition]}
                    else questionnaire
            in
            if questionnaire.editMode == False then
                ( { questionnaire
                    | elements = append questionnaire.elements [ questionnaire.newElement ]
                    , conditions = if (isConditionValid questionnaire.newCondition) then (append questionnaire.conditions [ questionnaire.newCondition ]) else questionnaire.conditions
                    , newCondition = initCondition
                    , showNewQuestionModal = False
                  }
                  
                , Cmd.none
                )

            else
                ( { questionnaire
                    | elements = List.map (\e -> updateElement questionnaire.newElement e) questionnaire.elements
                    , conditions = List.map (\e -> updateCondition questionnaire.newCondition e) questionnaire.conditions
                    , showNewQuestionModal = False
                    , editMode = False
                  }
                , Cmd.none
                )

        SetAnswer ->                                                                    
            case questionnaire.newElement of
                Question record ->
                    ({ questionnaire
                        | newElement =
                            Question { record | answers = record.answers ++ [ questionnaire.newAnswer ] }
                        , showNewAnswerModal = False
                    }, Cmd.none)

                Note record ->
                    (questionnaire, Cmd.none)    

        --Edits already existing elements

        EditAnswer element ->
            ({ questionnaire
                | newAnswer = element
                , showNewAnswerModal = True
            }, Cmd.none)

        EditQuestion element ->
            ( { questionnaire
                | newElement = element
                , newCondition = getConditionWithParentID questionnaire.conditions (getID element)
                , showNewQuestionModal = True
                , editMode = True
              }
            , Cmd.none
            )

        EditNote element ->
            ( { questionnaire
                | newElement = element
                , showNewNoteModal = True
                , editMode = True
              }
            , Cmd.none
            ) 

        EditQuestionnaire ->
            ( { questionnaire | upload = False, editQuestionnaire = True }, Cmd.none )

        --Change order of elements
        PutDownEl element ->
            if (getID element) /= ((List.length questionnaire.elements) - 1) 
            then ({ questionnaire 
                    | elements = putElementDown questionnaire.elements element 
                    , conditions = updateConditionWithIdTo questionnaire.conditions (getID element) ((getID element ) - 1)}
                , Cmd.none)
            else (questionnaire, Cmd.none)

        PutUpEl element ->
            if (getID element) /= 0
            then ({ questionnaire 
                    | elements = putElementUp questionnaire.elements element 
                    , conditions = updateConditionWithIdTo questionnaire.conditions (getID element) ((getID element ) + 1)}
                , Cmd.none)
            else (questionnaire, Cmd.none)

        PutUpAns answer ->
            if answer.id /= 0
            then ({ questionnaire 
                    | newElement = putAnswerUp questionnaire.newElement answer
                    , conditions = updateConditionAnswers questionnaire.conditions answer.id (answer.id - 1) }
                , Cmd.none)
            else (questionnaire, Cmd.none)

        PutDownAns answer ->
            if answer.id /= ((List.length (getAntworten questionnaire.newElement)) - 1)
            then ({ questionnaire | newElement = putAnswerDown questionnaire.newElement answer }, Cmd.none)
            else (questionnaire, Cmd.none)

        --Delete existing elements or answers
        DeleteItem element ->
            ({ questionnaire 
                | elements = deleteItemFrom element questionnaire.elements
                , conditions = deleteConditionWithElement questionnaire.conditions (getID element) }
            , Cmd.none)

        DeleteAnswer answer ->
            ({ questionnaire 
                | newElement = deleteAnswerFromItem answer questionnaire.newElement
                , conditions = List.map (deleteAnswerInCondition answer.id) questionnaire.conditions }, Cmd.none)

        -- validate inputs on submit and then save changes
        Submit ->
            if validate questionnaire == ValidationOK then
                ( { questionnaire
                    | validationResult = ValidationOK
                    , showViewingTimeModal = False
                    , showEditTimeModal = False
                    , editTime = questionnaire.inputEditTime
                    , viewingTimeBegin = questionnaire.inputViewingTimeBegin
                    , viewingTimeEnd = questionnaire.inputViewingTimeEnd
                  }
                , Cmd.none
                )

            else
                ( { questionnaire
                    | validationResult = validate questionnaire
                    , inputViewingTimeBegin = ""
                    , inputViewingTimeEnd = ""
                    , inputEditTime = ""
                  }
                , Cmd.none
                )        

        --Everything releated to upload

        EnterUpload ->
            ( { questionnaire
                | upload = True
              }
            , Cmd.none
            )

        LeaveOrEnterUpload ->
            ( { questionnaire
                | upload = not questionnaire.upload
              }
            , Cmd.none
            )

        JsonRequested ->
            ( questionnaire
            , Select.file [ "text/json" ] JsonSelected
            )

        JsonSelected file ->
            ( questionnaire
            , Task.perform JsonLoaded (File.toString file)
            )

        JsonLoaded content ->
            ( { questionnaire
                | title = decodeTitle content
                , elements = decodeElements content
                , upload = False
                , editQuestionnaire = True
              }
            , Cmd.none
            )

        --Everything releated to download
        DownloadQuestionnaire ->
            ( questionnaire, save questionnaire (encodeQuestionnaire questionnaire) )


--helper for changing order of elements
putElementDown : List Q_element -> Q_element -> List Q_element
putElementDown list element = 
    swapAt (getID element) ((getID element) + 1) (List.map (updateID (getID element) ((getID element) + 1)) list)
    --List.map (updateID (getID element) ((getID element) + 1)) list


putElementUp : List Q_element -> Q_element -> List Q_element
putElementUp list element = 
    swapAt (getID element) ((getID element) - 1) (List.map (updateID (getID element) ((getID element) - 1)) list)


putAnswerUp : Q_element -> Answer -> Q_element
putAnswerUp newElement answer =
    case newElement of 
        Note record ->
            Note record

        Question record ->
            Question { record | answers = swapAt answer.id (answer.id - 1) (List.map (updateAnsID answer.id (answer.id - 1)) record.answers)}


putAnswerDown : Q_element -> Answer -> Q_element
putAnswerDown newElement answer =
    case newElement of 
        Note record ->
            Note record

        Question record ->
            Question { record | answers = swapAt answer.id (answer.id + 1) (List.map (updateAnsID answer.id (answer.id + 1)) record.answers)}


setNewID : Q_element -> Int -> Q_element
setNewID element new =
    case element of 
        Note record ->
            Note { record | id = new }

        Question record -> 
            Question { record | id = new }


updateID : Int -> Int -> Q_element -> Q_element
updateID old new element =   
    if (getID element) == old then (setNewID element new)
    else if (getID element) == new then (setNewID element old) 
    else element


updateAnsID : Int -> Int -> Answer -> Answer
updateAnsID old new answer =
    if answer.id == old then { answer | id = new }
    else if answer.id == new then { answer | id = old }
    else answer


updateConditionWithIdTo : List Condition -> Int -> Int -> List Condition
updateConditionWithIdTo list old new =
    List.map (updateConditionID old new) list


updateConditionID : Int -> Int -> Condition -> Condition
updateConditionID old new condition = 
    { condition | child_id = getNewConditionID condition.child_id old new
                , parent_id = getNewConditionID condition.parent_id old new }
    -- das setzt child und parent ids auf den gleichen wert! TODO
    
getNewConditionID : Int -> Int -> Int -> Int
getNewConditionID cond_id old new =
    if cond_id == old then new
    else if cond_id == new then old
    else cond_id


updateConditionAnswers : List Condition -> Int -> Int -> List Condition
updateConditionAnswers list old new = 
    List.map (updateConditionWithAnswer old new) list


updateConditionWithAnswer : Int -> Int -> Condition -> Condition 
updateConditionWithAnswer old new condition = 
    { condition | answers = List.map (updateConditionAnswer old new) condition.answers }


updateConditionAnswer : Int -> Int -> Answer -> Answer
updateConditionAnswer old new answer = 
    if answer.id == old then { answer | id = new }
    else if answer.id == new then { answer | id = old }
    else answer


deleteConditionWithElement : List Condition -> Int -> List Condition
deleteConditionWithElement list id = 
    deleteConditionWithParent (deleteConditionWithChild list id) id


deleteConditionWithParent : List Condition -> Int -> List Condition
deleteConditionWithParent list id = 
    Tuple.first (List.partition (\e -> e.parent_id /= id) list)


deleteConditionWithChild : List Condition -> Int -> List Condition
deleteConditionWithChild list id = 
    Tuple.first (List.partition (\e -> e.child_id /= id) list)


deleteAnswerInCondition : Int -> Condition -> Condition
deleteAnswerInCondition id condition =
    { condition | answers = deleteCondAnswer condition.answers id }


deleteCondAnswer : List Answer -> Int -> List Answer
deleteCondAnswer list id =
    Tuple.first (List.partition (\answer -> answer.id /= id) list) 


setParentChildInCondition : Int -> Int -> Condition -> Condition
setParentChildInCondition parent child condition =
    { condition
        | parent_id = parent
        , child_id = child 
    }


setAnswersInCondition : List Answer -> Condition -> Condition
setAnswersInCondition list condition = 
    { condition
        | answers = list
    }


addAnswerOfQuestionToCondition : Int -> Q_element -> Condition -> Condition
addAnswerOfQuestionToCondition id newElement condition =
    case getAnswerWithID id newElement of 
        Just newAnswer ->
            { condition | answers = condition.answers ++ [newAnswer]}
        Nothing ->
            condition


getAnswerWithID : Int -> Q_element -> Maybe Answer
getAnswerWithID id newElement = 
    case newElement of 
        Question record ->
            List.head (Tuple.first (List.partition (\e -> e.id == id) record.answers))

        Note record ->
            Nothing


getAntworten : Q_element -> List Answer                            
getAntworten element =
    case element of
        Question record ->
            record.answers

        Note record ->
            []


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


updateElementList : Q_element -> List Q_element -> List Q_element
updateElementList elementToUpdate list =
    List.map (updateElement elementToUpdate) list


updateAnswerList : Answer -> List Answer -> List Answer
updateAnswerList answerToUpdate list =
    List.map (updateAnswer answerToUpdate) list


updateElement : Q_element -> Q_element -> Q_element
updateElement elementToUpdate element =
    if getID element == getID elementToUpdate then
        elementToUpdate

    else
        element


updateCondition : Condition -> Condition -> Condition
updateCondition conditionToUpdate condition =
    if condition.parent_id == conditionToUpdate.parent_id then
        conditionToUpdate

    else
        condition

isConditionValid : Condition -> Bool
isConditionValid condition = 
    if((condition.child_id == -1) || (condition.parent_id == -1)) then False
    else True 


updateAnswer answerToUpdate answer =
    if getAnswerID answer == getAnswerID answerToUpdate then
        answerToUpdate

    else
        answer


getID : Q_element -> Int
getID element =
    case element of
        Question record ->
            record.id

        Note record ->
            record.id


getText : Q_element -> String
getText element =
    case element of
        Question record ->
            record.text

        Note record ->
            record.text


getConditionWithParentID : List Condition -> Int -> Condition
getConditionWithParentID list id = 
    case List.head (Tuple.first (List.partition (\e -> e.parent_id == id) list)) of
        Just condition ->
            condition
        Nothing ->
            initCondition


getElementWithText : String -> Questionnaire -> Q_element
getElementWithText string questionnaire =
    case List.head (Tuple.first (List.partition (\e -> getText e == string) questionnaire.elements)) of 
        Just element ->
            element
        Nothing ->
            initQuestion

getAnswerID : Answer -> Int
getAnswerID answer = answer.id


deleteItemFrom : Q_element -> List Q_element -> List Q_element
deleteItemFrom element list =
    Tuple.first (List.partition (\e -> e /= element) list)


deleteAnswerFromItem : Answer -> Q_element -> Q_element
deleteAnswerFromItem answer element =
    case element of 
        Question record ->
            Question { record | answers = Tuple.first (List.partition (\e -> e /= answer) record.answers) }
        Note record ->
            Note record

-- Input Validation


validate : Questionnaire -> ValidationResult
validate questionnaire =
    if not (isValidEditTime questionnaire.inputEditTime) then
        Error "Die Bearbeitungszeit muss das Format HH:MM haben"

    else if not (isValidViewingTime questionnaire.inputViewingTimeBegin) then
        Error "Die Zeiten müssen das Format DD:MM:YYYY:HH:MM haben"

    else if not (isValidViewingTime questionnaire.inputViewingTimeEnd) then
        Error "Die Zeiten müssen das Format DD:MM:YYYY:HH:MM haben"

    else
        ValidationOK


isValidViewingTime : String -> Bool
isValidViewingTime viewingTime =
    not (String.length viewingTime /= 16 && String.length viewingTime /= 0)


isValidEditTime : String -> Bool
isValidEditTime editTime =
    not (String.length editTime /= 5 && String.length editTime /= 0)



-- getters for input boxes


getElementText : Q_element -> String
getElementText element =
    case element of
        Question record ->
            record.text

        Note record ->
            record.text

getAnswerText : Answer -> String                                           
getAnswerText answer = answer.text


getQuestionHinweis : Q_element -> String
getQuestionHinweis element =
    case element of
        Question record ->
            record.hint

        Note record ->
            "None"


getQuestionTyp : Q_element -> String
getQuestionTyp element =
    case element of
        Question record ->
            record.typ

        Note record ->
            "None"

getAnswerType : Answer -> String                                            
getAnswerType answer = answer.typ


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
    Decode.map2 NoteRecord
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        |> Decode.map Note



--decodes a question
questionDecoder : Decode.Decoder Q_element
questionDecoder =
    Decode.map5 QuestionRecord
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "answers" (Decode.list answerDecoder))
        (Decode.field "hint" Decode.string)
        (Decode.field "question_type" Decode.string)
        |> Decode.map Question



--decodes a answer
answerDecoder : Decode.Decoder Answer
answerDecoder =
    Decode.map3 Answer
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "_type" Decode.string)


--ENCODER


--encodes questionnaire as a json
encodeQuestionnaire : Questionnaire -> String
encodeQuestionnaire questionnaire =
    encode 4
        (object
            [ ( "title", Encode.string questionnaire.title )
            , ( "elements", Encode.list elementEncoder questionnaire.elements )
            , ( "conditions", Encode.list conditionEncoder questionnaire.conditions)
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


--View


view : Questionnaire -> Html Msg
view questionnaire =
    div []
        [ showNavbar
        , if questionnaire.upload then
            showUpload questionnaire

          else if questionnaire.editQuestionnaire then
            showEditQuestionnaire questionnaire

          else
            showEditQuestionnaire questionnaire
        ]



-- view helper functions


showHeroWith : String -> Html Msg
showHeroWith string =
    section [ class "hero is-primary" ]
        [ div [ class "hero-body" ]
            [ div [ class "container is-fluid" ]
                [ h1 [ class "title" ] [ text string ]
                ]
            ]
        ]


showNavbar : Html Msg
showNavbar =
    nav [ class "navbar is-link is-fixed-top" ]
        [ div [ class "navbar-brand" ]
            [ p [ class "navbar-item", style "padding-top" "0.5em" ] [ text "Fragebogengenerator" ] ]
        , div [ class "navbar-menu" ]
            [ div [ class "navbar-start" ]
                [ a [ class "navbar-item", onClick EditQuestionnaire ] [ text "Fragebogen Erstellen" ]
                , a [ class "navbar-item", onClick EnterUpload ] [ text "Fragebogen Hochladen" ]
                ]
            ]
        ]


showUpload : Questionnaire -> Html Msg
showUpload questionnaire =
    div []
        [ showHeroWith "Upload"
        , br [] []
        , div [ class "columns has-text-centered" ]
            [ div [ class "column" ]
                [ button [ onClick JsonRequested ] [ text "Datei auswählen" ]
                ]
            ]
        ]


showEditQuestionnaire : Questionnaire -> Html Msg
showEditQuestionnaire questionnaire =
    div []
        [ showHeroQuestionnaireTitle questionnaire
        , showQuestionList questionnaire
        , showTimes questionnaire
        , showCreateQuestionOrNoteButtons questionnaire
        , viewTitleModal questionnaire
        , viewEditTimeModal questionnaire
        , viewViewingTimeModal questionnaire
        , viewNewNoteModal questionnaire
        , viewNewQuestionModal questionnaire
        , viewNewAnswerModal questionnaire
        , viewConditions questionnaire
        ]

viewConditions : Questionnaire -> Html Msg
viewConditions questionnaire = 
    div[] (List.map (\c -> text ("("++String.fromInt c.parent_id++","++String.fromInt c.child_id++")")) questionnaire.conditions)


showHeroQuestionnaireTitle : Questionnaire -> Html Msg
showHeroQuestionnaireTitle questionnaire =
    section [ class "hero is-primary" ]
        [ div [ class "hero-body" ]
            [ div [ class "container is-fluid" ]
                [ h1 [ class "title" ]
                    [ text questionnaire.title
                    , i
                        [ class "fas fa-cog"
                        , style "margin-left" "10px"
                        , onClick (ViewOrClose TitleModal)
                        ]
                        []
                    ]
                ]
            ]
        ]


showQuestionList : Questionnaire -> Html Msg
showQuestionList questionnaire =
    div [ class "box container is-fluid", style "flex-basis" "80%", style "overflow-y" "auto", style "height" "60vh",style "margin-top" "2em", style "margin-bottom" "2em" ]
        [ table [ class "table is-striped" 
                ] 
                [ thead [
                        ] 
                        [ (tableHead_questions) 
                        ]
                , tbody [
                        ]
                        (questionsTable questionnaire) 
                ]
                
        ]


showTimes : Questionnaire -> Html Msg
showTimes questionnaire =
    div [ class "container is-fluid", style "margin-bottom" "10px" ]
        [ text ("Bearbeitungszeit: " ++ getViewingTime questionnaire)
        , i
            [ class "fas fa-cog"
            , style "margin-left" "10px"
            , onClick (ViewOrClose EditTimeModal)
            ]
            []
        , br [] []
        , text ("Erscheinungszeit: " ++ getEditTime questionnaire)
        , i
            [ class "fas fa-cog"
            , style "margin-left" "10px"
            , onClick (ViewOrClose ViewingTimeModal)
            ]
            []
        ]


showCreateQuestionOrNoteButtons : Questionnaire -> Html Msg
showCreateQuestionOrNoteButtons questionnaire =
    div [ class "container is-fluid" ]
        [ button
            [ style "margin-right" "10px"
            , onClick (ViewOrClose QuestionModal)
            ]
            [ text "Neue Frage" ]
        , button [ onClick (ViewOrClose NewNoteModal) ]
            [ text "Neue Anmerkung" ]
        , br [] []
        , br [] []
        , button [ onClick DownloadQuestionnaire ] [ text "Download" ]
        ]



-- Show Viewing time and Edit time


getViewingTime : Questionnaire -> String
getViewingTime questionnaire =
    if questionnaire.editTime == "" then
        "unbegrenzt"

    else
        questionnaire.editTime


getEditTime : Questionnaire -> String
getEditTime questionnaire =
    if questionnaire.viewingTimeBegin == "" then
        "unbegrenzt"

    else
        "Von " ++ questionnaire.viewingTimeBegin ++ " Bis " ++ questionnaire.viewingTimeEnd


--MODALS


viewViewingTimeModal : Questionnaire -> Html Msg
viewViewingTimeModal questionnaire =
    if questionnaire.showViewingTimeModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head" ]
                    [ p [ class "modal-card-title" ] [ text "Erscheinungszeit" ] ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "Von "
                        , input
                            [ class "input"
                            , type_ "text"
                            , placeholder "DD:MM:YYYY:HH:MM"
                            , value questionnaire.inputViewingTimeBegin
                            , maxlength 16
                            , minlength 16
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , style "margin-right" "10px"
                            , onInput ChangeViewingTimeBegin
                            ]
                            []
                        , text " Bis "
                        , input
                            [ class "input"
                            , type_ "text"
                            , placeholder "DD:MM:YYYY:HH:MM"
                            , value questionnaire.inputViewingTimeEnd
                            , maxlength 16
                            , minlength 16
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , onInput ChangeViewingTimeEnd
                            ]
                            []
                        ]
                    , br [] []
                    , viewValidation questionnaire
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button
                        [ class "button is-success"
                        , onClick Submit
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            , button
                [ class "modal-close is-large"
                , onClick (ViewOrClose ViewingTimeModal)
                ]
                []
            ]

    else
        div [] []


viewEditTimeModal : Questionnaire -> Html Msg
viewEditTimeModal questionnaire =
    if questionnaire.showEditTimeModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head" ]
                    [ p [ class "modal-card-title" ] [ text "Bearbeitungszeit" ] ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "Zeit: "
                        , input
                            [ class "input"
                            , type_ "text"
                            , placeholder "HH:MM"
                            , value questionnaire.inputEditTime
                            , maxlength 5
                            , minlength 5
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , style "margin-right" "10px"
                            , onInput ChangeEditTime
                            ]
                            []
                        , br [] []
                        , viewValidation questionnaire
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button
                        [ class "button is-success"
                        , onClick Submit
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            , button
                [ class "modal-close is-large"
                , onClick (ViewOrClose EditTimeModal)
                ]
                []
            ]

    else
        div [] []


viewTitleModal : Questionnaire -> Html Msg
viewTitleModal questionnaire =
    if questionnaire.showTitleModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head" ]
                    [ p [ class "modal-card-title" ] [ text "Titel ändern" ] ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "Text: "
                        , input
                            [ class "input"
                            , type_ "text"
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , style "margin-right" "10px"
                            , value questionnaire.title
                            , onInput ChangeQuestionnaireTitle
                            ]
                            []
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button
                        [ class "button is-success"
                        , onClick (ViewOrClose TitleModal)
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            , button
                [ class "modal-close is-large"
                , onClick (ViewOrClose TitleModal)
                ]
                []
            ]

    else
        div [] []


viewNewNoteModal : Questionnaire -> Html Msg
viewNewNoteModal questionnaire =
    if questionnaire.showNewNoteModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head" ]
                    [ p [ class "modal-card-title" ] [ text "Neue Anmerkung" ] ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "Text: "
                        , input
                            [ class "input"
                            , type_ "text"
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , style "margin-right" "10px"
                            , value (getElementText questionnaire.newElement)
                            , onInput ChangeQuestionOrNoteText
                            ]
                            []
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button
                        [ class "button is-success"
                        , onClick SetNote
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            , button
                [ class "modal-close is-large"
                , onClick (ViewOrClose NewNoteModal)
                ]
                []
            ]

    else
        div [] []


viewNewQuestionModal : Questionnaire -> Html Msg
viewNewQuestionModal questionnaire =
    if questionnaire.showNewQuestionModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head" ]
                    [ p [ class "modal-card-title" ] [ text "Neue Frage" ] ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ table [ class "table is-striped", style "width" "100%" ] (answersTable questionnaire)
                        , br [] []
                        , button [ style "margin-bottom" "10px" , onClick (ViewOrClose AnswerModal) ] [ text "Neue Antwort" ]
                        , br [] []
                        , showInputBipolarUnipolar questionnaire
                        , br [] []
                        , text "Fragetext: "
                        , input
                            [ class "input"
                            , type_ "text"
                            , style "width" "100%"
                            , value (getElementText questionnaire.newElement)
                            , onInput ChangeQuestionOrNoteText
                            ]
                            []
                        , br [] []
                        , text "Hinweis: "
                        , input
                            [ class "input"
                            , type_ "text"
                            , style "width" "100%"
                            , value (getQuestionHinweis questionnaire.newElement)
                            , onInput ChangeQuestionNote
                            ]
                            []
                        , br [] []
                        , text ("Typ: " ++ getQuestionTyp questionnaire.newElement)
                        , br [] []
                        , radio "Single Choice" (ChangeQuestionType "Single Choice")
                        , radio "Multiple Choice" (ChangeQuestionType "Multiple Choice")
                        , radio "Ja/Nein Frage" (ChangeQuestionType "Ja/Nein Frage")
                        , radio "Skaliert unipolar" (ChangeQuestionType "Skaliert unipolar")
                        , radio "Skaliert bipolar" (ChangeQuestionType "Skaliert bipolar")
                        , br [] []
                        , text "Springe zu Frage: "
                        , br [] []
                        , div [ class "select" ]
                            [ select [ onInput AddCondition ]
                                (getQuestionOptions questionnaire.elements questionnaire.newElement)
                            ]
                        , br [] []
                        , text "Bei Beantwortung der Antworten mit den IDs: "
                        , text (Debug.toString (List.map getAnswerID questionnaire.newCondition.answers)) 
                        , br [] []
                        , input 
                            [ placeholder "Hier ID eingeben"
                            , onInput AddAnswerToNewCondition ] 
                            []
                        , button 
                            [ class "button"
                            , style "margin-left" "1em" 
                            , style "margin-top" "0.25em"
                            , onClick AddConditionAnswer ] 
                            [ text "Hinzufügen" ]
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button
                        [ class "button is-success"
                        , onClick SetQuestion
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            , button
                [ class "modal-close is-large"
                , onClick (ViewOrClose QuestionModal)
                ]
                []
            ]

    else
        div [] []


getQuestionOptions : List Q_element -> Q_element -> List (Html Msg)
getQuestionOptions list newElement =
    [ option [] [ text "Keine" ] ]
        ++ List.map (\e -> option [] [ text ((String.fromInt (getElementId e)) ++"."++" "++getElementText e) ]) list

getElementId : Q_element -> Int
getElementId elem = 
    case elem of
        Question a -> a.id
        Note a -> a.id


viewNewAnswerModal : Questionnaire -> Html Msg
viewNewAnswerModal questionnaire =
    if questionnaire.showNewAnswerModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head" ]
                    [ p [ class "modal-card-title" ] [ text "Neue Antwort" ] ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "Antworttext: "
                        , input
                            [ class "input"
                            , type_ "text"
                            , style "width" "100%"         
                            , onInput ChangeAnswerText                                  
                            ]
                            []
                        ]
                    , br [] []
                    , div []
                        [ text ("Typ: " ++ getAnswerType questionnaire.newAnswer)                       
                        , br [] []
                        , radio "Fester Wert" (ChangeAnswerType "regular")      
                        , radio "Freie Eingabe" (ChangeAnswerType "free")  
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button
                        [ class "button is-success"
                        , onClick SetAnswer
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            , button
                [ class "modal-close is-large"
                , onClick (ViewOrClose AnswerModal)
                ]
                []
            ]

    else
        div [] []


-- Show input for bipolar and unipolar Question


showInputBipolarUnipolar : Questionnaire -> Html Msg
showInputBipolarUnipolar questionnaire =
    case questionnaire.newElement of
        Question record ->
            if record.typ == "Skaliert unipolar" then
                div []
                    [ text "Bitte Anzahl Antworten (insgesamt) eingeben"
                    , input
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "10px"
                        , style "margin-top" "2px"
                        , onInput SetPolarAnswers
                        ]
                        []
                    ]
            else if record.typ == "Skaliert bipolar" then
                div []
                    [ text "Bitte Anzahl Antworten (pro Skalenrichtung) eingeben"
                    , input
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "10px"
                        , style "margin-top" "2px"
                        , onInput SetPolarAnswers
                        ]
                        []
                    ]
            else 
                div [] []

        Note record ->
            div [] []



--radio button control


radio : String -> msg -> Html msg
radio value msg =
    label
        [ style "padding" "20px" ]
        [ input
            [ type_ "radio"
            , name "font-size"
            , onClick msg
            ]
            []
        , text value
        ]



--Table of Questions


questionsTable : Questionnaire -> List (Html Msg)
questionsTable questionnaire =
    {--[ tableHead_questions ]
        ++--}
    List.indexedMap getQuestionTable questionnaire.elements


tableHead_questions : Html Msg
tableHead_questions =
    tr []
        [ th [style "width" "5%"]
             [ text "ID"
             ]
        , th [style "width" "40%"]
             [ text "Fragetext"
             ]
        , th [style "width" "25%"]
             [ text "Hinweis"
             ]
        , th [style "width" "20%"]
             [ text "Typ"
             ]
        , th [style "width" "10%"]
             [ text "Aktion"
             ]
        ]
    


getQuestionTable : Int -> Q_element -> Html Msg
getQuestionTable index element =
    case element of
        Note a ->
            tr [ id (String.fromInt index) ]
                [ td [style "width" "5%"] [ text (String.fromInt index) ]
                , td [style "width" "40%"] [ text a.text ]
                , td [style "width" "25%"] []
                , td [style "width" "20%"] []
                , td [style "width" "10%"]
                    [ i 
                        [ class "fas fa-arrow-up"
                        , onClick (PutUpEl element) ]
                        []
                    , i 
                        [ class "fas fa-arrow-down"
                        , onClick (PutDownEl element)
                        , style "margin-left" "1em"
                        , style "margin-right" "1em" ]
                        []
                    , i
                        [ class "fas fa-cog"
                        , onClick (EditNote element)
                        , style "margin-right" "1em"
                        ]
                        []
                    , i
                        [ class "fas fa-trash-alt"
                        , onClick (DeleteItem element)
                        ]
                        []
                    ]
                ]

        Question f ->
            tr [ id (String.fromInt index) ]
                [ td [style "width" "5%"] [ text (String.fromInt index) ]
                , td [style "width" "40%"] [ text f.text ]
                , td [style "width" "25%"] [ text f.hint ]
                , td [style "width" "20%"] [ text f.typ ]
                , td [style "width" "10%"]
                    [ i 
                        [ class "fas fa-arrow-up"
                        , onClick (PutUpEl element) ] 
                        []
                    , i 
                        [ class "fas fa-arrow-down"
                        , onClick (PutDownEl element) 
                        , style "margin-left" "1em"
                        , style "margin-right" "1em"]
                        []
                    , i
                        [ class "fas fa-cog"
                        , onClick (EditQuestion element)
                        , style "margin-right" "1em"]
                        []
                    , i
                        [ class "fas fa-trash-alt"
                        , onClick (DeleteItem element)
                        ]
                        []
                    ]
                ]



--Table of Answers


answersTable : Questionnaire -> List (Html Msg)
answersTable questionnaire =
    case questionnaire.newElement of
        Question record ->
            append [ tableHead_answers ] (List.indexedMap getAnswerTable (getAntworten questionnaire.newElement))

        Note record ->
            []


tableHead_answers : Html Msg
tableHead_answers =
    tr []
        [ th []
            [ text "ID"
            ]
        , th []
            [ text "Text"
            ]
        , th []
            [ text "Typ"
            ]
        , th []
            [ text "Aktion"
            ]
        ]


getAnswerTable : Int -> Answer -> Html Msg
getAnswerTable index answer =
    tr [ id (String.fromInt index) ]
        [ td [] [ text (String.fromInt index) ]
        , td [] [ text answer.text ]
        , td [] [ text answer.typ ]
        , td []
            [ i 
                [ class "fas fa-arrow-up"
                , onClick (PutUpAns answer) ] 
                []
            , i 
                [ class "fas fa-arrow-down"
                , onClick (PutDownAns answer)
                , style "margin-left" "1em"
                , style "margin-right" "1em" ]
                []
            , i
                [ class "fas fa-cog"
                , style "margin-right" "1em"
                , onClick (EditAnswer answer)
                ]
                []
            , i 
                [ class "fas fa-trash-alt" 
                , onClick (DeleteAnswer answer)
                ] 
                []
            ]
        ]


--Error Message for viewTime and editTime modals


viewValidation : Questionnaire -> Html msg
viewValidation questionnaire =
    let
        ( color, message ) =
            case questionnaire.validationResult of
                NotDone ->
                    ( "", "" )

                Error msg ->
                    ( "red", msg )

                ValidationOK ->
                    ( "green", "OK" )
    in
    div [ style "color" color ] [ text message ]
