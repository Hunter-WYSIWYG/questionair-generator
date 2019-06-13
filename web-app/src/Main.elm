module Main exposing (Answer, FB_element(..), Msg(..), Questionnaire, ValidationResult(..), answersTable, deleteItemFrom, getAnswerTable, getEditTime, getElementText, getID, getQuestionHinweis, getQuestionTable, getQuestionTyp, getViewingTime, initQuestion, initQuestionnaire, main, questionsTable, radio, tableHead_answers, tableHead_questions, update, updateElement, updateElementList, validate, view, viewEditTimeModal, viewNewNoteModal, viewNewQuestionModal, viewTitleModal, viewValidation, viewViewingTimeModal)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, a, br, button, div, footer, form, h1, header, i, input, label, p, section, table, td, text, th, tr)
import Html.Attributes exposing (class, href, id, maxlength, minlength, multiple, name, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput, on)
import Json.Decode as Decode
import List exposing (append)
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
    | ChangeQuestionNewAnswer Answer
    | ChangeQuestionNote String
    | ChangeQuestionType String
      --Modals
    | ViewOrClose ModalType
      --Other
    | SetNote
    | SetQuestion
    | SetPolarAnswers String
    | EditQuestion FB_element
    | EditNote FB_element
    | DeleteItem FB_element
    | Submit
    | LeaveOrEnterMenu
    | LeaveOrEnterUpload
    | JsonRequested
    | JsonSelected File
    | JsonLoaded String


type ModalType
    = ViewingTimeModal
    | EditTimeModal
    | NewNoteModal
    | QuestionModal
    | TitleModal


type alias Questionnaire =
    { title : String
    , elements : List FB_element

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

    --newInputs
    , validationResult : ValidationResult
    , inputEditTime : String
    , inputViewingTimeBegin : String
    , inputViewingTimeEnd : String
    , newElement : FB_element

    --editMode for EditQuestion and EditNote
    , editMode : Bool

    --menu determines whether we are in the main menu
    , menu : Bool

    --upload determines if the users wants to upload a questionnaire
    --if upload is false show UI to create new questionnaire
    , upload : Bool

    --Debug
    , tmp : String
    }


type FB_element
    = Note NoteRecord
    | Question QuestionRecord


type alias NoteRecord = 
    { id : Int
    , text : String
    }


type alias QuestionRecord =
    { id : Int
    , text : String
    , antworten : List Answer
    , hinweis : String
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


initQuestionnaire : () -> (Questionnaire, Cmd Msg)
initQuestionnaire _ =
    ({ title = "Neuer Fragebogen"
    , elements = [ initQuestion ]

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

    --new inputs
    , validationResult = NotDone
    , inputViewingTimeBegin = ""
    , inputViewingTimeEnd = ""
    , inputEditTime = ""
    , newElement = initQuestion

    --editMode
    , editMode = False

    , menu = True
    , upload = False
    , tmp = ""
    }
    , Cmd.none)

initQuestionnaire2 : (Questionnaire, Cmd Msg)
initQuestionnaire2 =
    ({ title = "Neuer Fragebogen"
    , elements = [ initQuestion ]

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

    --new inputs
    , validationResult = NotDone
    , inputViewingTimeBegin = ""
    , inputViewingTimeEnd = ""
    , inputEditTime = ""
    , newElement = initQuestion

    --editMode
    , editMode = False

    , menu = True
    , upload = False
    , tmp = ""
    }
    , Cmd.none)

--Beispielfrage


initQuestion : FB_element
initQuestion =
    Question
        { id = 0
        , text = "Wie geht's?"
        , antworten = []
        , hinweis = "Das ist eine Frage"
        , typ = "Single Choice"
        }



--Update logic


update : Msg -> Questionnaire -> (Questionnaire, Cmd Msg)
update msg questionnaire =
    case msg of
        --changing input
        ChangeQuestionnaireTitle newTitle ->
            ({ questionnaire | title = newTitle }, Cmd.none)

        ChangeEditTime newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputEditTime = newTime
                    }
            in
            ({ changedQuestionnaire
                | validationResult = validate changedQuestionnaire
            }, Cmd.none)

        ChangeViewingTimeBegin newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputViewingTimeBegin = newTime
                    }
            in
            ({ changedQuestionnaire
                | validationResult = validate changedQuestionnaire
            }, Cmd.none)

        ChangeViewingTimeEnd newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputViewingTimeEnd = newTime
                    }
            in
            ({ changedQuestionnaire
                | validationResult = validate changedQuestionnaire
            }, Cmd.none)

        ChangeQuestionOrNoteText string ->
            let
                changedRecord rec =
                    { rec | text = string }
            in
            case questionnaire.newElement of
                Question record ->
                    ({ questionnaire | newElement = Question (changedRecord record) }, Cmd.none)

                Note record ->
                    ({ questionnaire | newElement = Note (changedRecord record) }, Cmd.none)

        ChangeQuestionNewAnswer newAnswer ->
            case questionnaire.newElement of
                Question record ->
                    ({ questionnaire
                        | newElement =
                            Question
                                { record | antworten = record.antworten ++ [ newAnswer ] }
                    }, Cmd.none)

                Note record ->
                    (questionnaire, Cmd.none)

        ChangeQuestionNote string ->
            case questionnaire.newElement of
                Question record ->
                    ({ questionnaire
                        | newElement =
                            Question
                                { record | hinweis = string }
                    }, Cmd.none)

                Note record ->
                    (questionnaire, Cmd.none)

        ChangeQuestionType string ->
            case questionnaire.newElement of
                Question record ->
                    ({ questionnaire
                        | newElement =
                            Question
                                { record | typ = string, antworten = (setPredefinedAnswers string) }
                    }, Cmd.none)

                Note record ->
                    (questionnaire, Cmd.none)

        --open or close modals
        ViewOrClose modalType ->
            case modalType of
                TitleModal ->
                    ({ questionnaire | showTitleModal = not questionnaire.showTitleModal }, Cmd.none)

                ViewingTimeModal ->
                    ({ questionnaire | showViewingTimeModal = not questionnaire.showViewingTimeModal }, Cmd.none)

                EditTimeModal ->
                    ({ questionnaire | showEditTimeModal = not questionnaire.showEditTimeModal }, Cmd.none)

                NewNoteModal ->
                    let
                        changedQuestionnaire =
                            { questionnaire | showNewNoteModal = not questionnaire.showNewNoteModal }
                    in
                    if changedQuestionnaire.showNewNoteModal == True then
                        ({ changedQuestionnaire
                            | newElement =
                                Note
                                    { id = List.length questionnaire.elements
                                    , text = ""
                                    }
                        }, Cmd.none)

                    else
                        (changedQuestionnaire, Cmd.none)

                QuestionModal ->
                    let
                        changedQuestionnaire =
                            { questionnaire | showNewQuestionModal = not questionnaire.showNewQuestionModal }
                    in
                    if changedQuestionnaire.showNewQuestionModal == True then
                        ({ changedQuestionnaire
                            | newElement =
                                Question
                                    { id = List.length questionnaire.elements
                                    , text = ""
                                    , antworten = []
                                    , hinweis = ""
                                    , typ = ""
                                    }
                        }, Cmd.none)

                    else
                        (changedQuestionnaire, Cmd.none)

        --Other
        DeleteItem element ->
            ({ questionnaire | elements = deleteItemFrom element questionnaire.elements }, Cmd.none)

        -- validate inputs on submit and then save changes
        Submit ->
            if validate questionnaire == ValidationOK then
                ({ questionnaire
                    | validationResult = ValidationOK
                    , showViewingTimeModal = False
                    , showEditTimeModal = False
                    , editTime = questionnaire.inputEditTime
                    , viewingTimeBegin = questionnaire.inputViewingTimeBegin
                    , viewingTimeEnd = questionnaire.inputViewingTimeEnd
                }, Cmd.none)

            else
                ({ questionnaire
                    | validationResult = validate questionnaire
                    , inputViewingTimeBegin = ""
                    , inputViewingTimeEnd = ""
                    , inputEditTime = ""
                }, Cmd.none)

        SetPolarAnswers string ->
            case questionnaire.newElement of
                Question record ->
                    if record.typ == "Skaliert unipolar" 
                    then ({ questionnaire | newElement = Question { record | antworten = (getUnipolarAnswers string) } }, Cmd.none)
                    else ({ questionnaire | newElement = Question { record | antworten = (getBipolarAnswers string) } }, Cmd.none)
                Note record ->
                    (questionnaire, Cmd.none)

        SetNote ->
            if questionnaire.editMode == False then
                ({ questionnaire
                    | elements = append questionnaire.elements [ questionnaire.newElement ]
                    , showNewNoteModal = False
                }, Cmd.none)

            else
                ({ questionnaire
                    | elements = List.map (\e -> updateElement questionnaire.newElement e) questionnaire.elements
                    , showNewNoteModal = False
                    , editMode = False
                }, Cmd.none)

        SetQuestion ->
            if questionnaire.editMode == False then
                ({ questionnaire
                    | elements = append questionnaire.elements [ questionnaire.newElement ]
                    , showNewQuestionModal = False
                }, Cmd.none)

            else
                ({ questionnaire
                    | elements = List.map (\e -> updateElement questionnaire.newElement e) questionnaire.elements
                    , showNewQuestionModal = False
                    , editMode = False
                }, Cmd.none)

        EditQuestion element ->
            ({ questionnaire
                | newElement = element
                , showNewQuestionModal = True
                , editMode = True
            }, Cmd.none)

        EditNote element ->
            ({ questionnaire
                | newElement = element
                , showNewNoteModal = True
                , editMode = True
            }, Cmd.none)
        
        LeaveOrEnterMenu ->
            ({ questionnaire 
                | menu = not questionnaire.menu 
                , upload = False }, Cmd.none)

        LeaveOrEnterUpload ->
            ({ questionnaire 
                | menu = False
                , upload = not questionnaire.upload
            }, Cmd.none)
        
        --Json

        JsonRequested ->
            ( questionnaire
            , Select.file ["text/json"] JsonSelected
            )

        JsonSelected file ->
            ( questionnaire
            , Task.perform JsonLoaded (File.toString file)
            )

        JsonLoaded content ->
            (   { questionnaire 
                    | title = decodeTitle content 
                    , elements = decodeElements content
                }   
            , Cmd.none)


decodeTitle : String -> String
decodeTitle content =
    case Decode.decodeString (Decode.field "title" Decode.string) content of 
        Ok val ->
            val
        Err e ->
            ""


decodeElements : String -> List FB_element
decodeElements content = 
    case Decode.decodeString (Decode.at ["elements"] (Decode.list elementDecoder)) content of 
        Ok elements ->
            elements
        Err e ->
            []


elementDecoder : Decode.Decoder FB_element
elementDecoder = 
    Decode.oneOf [ noteDecoder, questionDecoder ]
    

noteDecoder : Decode.Decoder FB_element
noteDecoder =
    Decode.map2 NoteRecord
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        |> Decode.map Note

questionDecoder : Decode.Decoder FB_element
questionDecoder =
    Decode.map5 QuestionRecord
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "answers" (Decode.list answerDecoder))
        (Decode.field "hint" Decode.string) 
        (Decode.field "question_type" Decode.string)
        |> Decode.map Question

answerDecoder : Decode.Decoder Answer
answerDecoder = 
    Decode.map3 Answer
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "_type" Decode.string)


setPredefinedAnswers : String -> List Answer
setPredefinedAnswers questionType = 
    if questionType == "Ja/Nein Frage" then [ (regularAnswer 0 "Ja"), (regularAnswer 1 "Nein") ]
    else []


regularAnswer : Int -> String -> Answer
regularAnswer int string = 
    { id = int
    , text = string
    , typ = "regular" 
    }


getUnipolarAnswers : String -> List Answer
getUnipolarAnswers string = 
    case String.toInt string of 
        Nothing -> []
        Just val -> getAnswersWithRange 1 val 0


getBipolarAnswers : String -> List Answer
getBipolarAnswers string = 
    case String.toInt string of 
        Nothing -> []
        Just val -> getAnswersWithRange (-val) val 0


getAnswersWithRange : Int -> Int -> Int -> List Answer
getAnswersWithRange begin end index =
    if begin == end then [ regularAnswer index (String.fromInt end) ]
    else [ regularAnswer index (String.fromInt begin) ] ++ (getAnswersWithRange (begin+1) end (index+1))


updateElementList : FB_element -> List FB_element -> List FB_element
updateElementList elementToUpdate list =
    List.map (updateElement elementToUpdate) list


updateElement elementToUpdate element =
    if getID element == getID elementToUpdate then
        elementToUpdate

    else
        element


getID : FB_element -> Int
getID element =
    case element of
        Question record ->
            record.id

        Note record ->
            record.id


deleteItemFrom : FB_element -> List FB_element -> List FB_element
deleteItemFrom element list =
    Tuple.first (List.partition (\e -> e /= element) list)



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


getElementText : FB_element -> String
getElementText element =
    case element of
        Question record ->
            record.text

        Note record ->
            record.text


getQuestionHinweis : FB_element -> String
getQuestionHinweis element =
    case element of
        Question record ->
            record.hinweis

        Note record ->
            "None"


getQuestionTyp : FB_element -> String
getQuestionTyp element =
    case element of
        Question record ->
            record.typ

        Note record ->
            "None"



--View


view : Questionnaire -> Html Msg
view questionnaire =
    if questionnaire.menu then 
        showMenu
    else if questionnaire.upload then 
        showUpload questionnaire
    else
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

showMenu : Html Msg
showMenu = 
    div [] 
        [ showHeroWith "Hauptmenü"
        , div [ class "content has-text-centered", style "margin-top" "10px" ]
            [ div [ class "columns" ] 
                [ div [ class "column" ]
                    [ button [ onClick LeaveOrEnterMenu ] [ text "Fragebogen erstellen" ] 
                    ]
                , div [ class "column" ]
                    [ button [ onClick LeaveOrEnterUpload ] [ text "Fragebogen hochladen" ]
                    ]
                ]
            ]
        ]

showUpload questionnaire = 
    div [] 
        [ showHeroWith "Upload"
        , br [] []
        , div [ class "columns has-text-centered" ]
            [ div [ class "column" ]
                [ button [ onClick LeaveOrEnterMenu ] [ text "Zurück" ]
                ]
            , div [ class "column" ]
                [ button [ onClick JsonRequested ] [ text "Datei auswählen" ]
                ]
            ]    
        , text questionnaire.tmp
        ]

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
    div [ class "container is-fluid", style "margin-bottom" "10px" ]
        [ table [ class "table is-striped", style "width" "100%" ] (questionsTable questionnaire)
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
        , button [ onClick LeaveOrEnterMenu ] [ text "Hauptmenü" ]
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
                        , button [ style "margin-bottom" "10px" ] [ text "Neue Antwort" ]
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

-- Show input for bipolar and unipolar Question
showInputBipolarUnipolar : Questionnaire -> Html Msg
showInputBipolarUnipolar questionnaire = 
    case questionnaire.newElement of
        Question record ->
            if record.typ == "Skaliert unipolar" || record.typ == "Skaliert bipolar"
                then input 
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "10px"
                        , style "margin-top" "2px"
                        , placeholder "Anzahl Antworten"
                        , onInput SetPolarAnswers
                        ] []
            else div [] []
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
    append [ tableHead_questions ] (List.indexedMap getQuestionTable questionnaire.elements)


tableHead_questions : Html Msg
tableHead_questions =
    tr []
        [ th []
            [ text "ID"
            ]
        , th []
            [ text "Fragetext"
            ]
        , th []
            [ text "Hinweis"
            ]
        , th []
            [ text "Typ"
            ]
        , th []
            [ text "Aktion"
            ]
        ]


getQuestionTable : Int -> FB_element -> Html Msg
getQuestionTable index element =
    case element of
        Note a ->
            tr [ id (String.fromInt index) ]
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text a.text ]
                , td [] []
                , td [] []
                , td []
                    [ i
                        [ class "fas fa-cog"
                        , style "margin-right" "10px"
                        , onClick (EditNote element)
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
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text f.text ]
                , td [] [ text f.hinweis ]
                , td [] [ text f.typ ]
                , td []
                    [ i
                        [ class "fas fa-cog"
                        , style "margin-right" "10px"
                        , onClick (EditQuestion element)
                        ]
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
            append [ tableHead_answers ] (List.indexedMap getAnswerTable record.antworten)

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
            [ text "Aktion"
            ]
        ]


getAnswerTable : Int -> Answer -> Html Msg
getAnswerTable index element =
    tr [ id (String.fromInt index) ]
        [ td [] [ text (String.fromInt index) ]
        , td [] [ text element.text ]
        , td []
            [ i
                [ class "fas fa-cog"
                , style "margin-right" "10px"
                ]
                []
            , i [ class "fas fa-trash-alt" ] []
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
