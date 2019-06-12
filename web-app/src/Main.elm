module Main exposing (Answer, FB_element(..), Msg(..), Questionnaire, ValidationResult(..), answersTable, deleteItemFrom, getAnswerTable, getEditTime, getElementText, getID, getQuestionHinweis, getQuestionTable, getQuestionTyp, getViewingTime, initQuestion, initQuestionnaire, main, questionsTable, radio, tableHead_answers, tableHead_questions, update, updateElement, updateElementList, validate, view, viewEditTimeModal, viewNewNoteModal, viewNewQuestionModal, viewTitleModal, viewValidation, viewViewingTimeModal)

import Browser exposing (sandbox)
import Html exposing (Html, a, br, button, div, footer, form, h1, header, i, input, label, p, section, table, td, text, th, tr)
import Html.Attributes exposing (class, href, id, maxlength, minlength, name, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import List exposing (append)


main =
    Browser.sandbox { init = initQuestionnaire, view = view, update = update }



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
    | EditQuestion FB_element
    | EditNote FB_element
    | DeleteItem FB_element
    | Submit


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
    }


type FB_element
    = Note
        { id : Int
        , text : String
        }
    | Question
        { id : Int
        , text : String
        , antworten : List Answer
        , hinweis : String
        , typ : String
        }


type alias Answer =
    { id : Int
    , text : String

    --, type : String
    }


type ValidationResult
    = NotDone
    | Error String
    | ValidationOK



--Init


initQuestionnaire : Questionnaire
initQuestionnaire =
    { title = "Neuer Fragebogen"
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
    }



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


update : Msg -> Questionnaire -> Questionnaire
update msg questionnaire =
    case msg of
        --changing input
        ChangeQuestionnaireTitle newTitle ->
            { questionnaire | title = newTitle }

        ChangeEditTime newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputEditTime = newTime
                    }
            in
            { changedQuestionnaire
                | validationResult = validate changedQuestionnaire
            }

        ChangeViewingTimeBegin newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputViewingTimeBegin = newTime
                    }
            in
            { changedQuestionnaire
                | validationResult = validate changedQuestionnaire
            }

        ChangeViewingTimeEnd newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputViewingTimeEnd = newTime
                    }
            in
            { changedQuestionnaire
                | validationResult = validate changedQuestionnaire
            }

        ChangeQuestionOrNoteText string ->
            let
                changedRecord rec =
                    { rec | text = string }
            in
            case questionnaire.newElement of
                Question record ->
                    { questionnaire | newElement = Question (changedRecord record) }

                Note record ->
                    { questionnaire | newElement = Note (changedRecord record) }

        ChangeQuestionNewAnswer newAnswer ->
            case questionnaire.newElement of
                Question record ->
                    { questionnaire
                        | newElement =
                            Question
                                { record | antworten = record.antworten ++ [ newAnswer ] }
                    }

                Note record ->
                    questionnaire

        ChangeQuestionNote string ->
            case questionnaire.newElement of
                Question record ->
                    { questionnaire
                        | newElement =
                            Question
                                { record | hinweis = string }
                    }

                Note record ->
                    questionnaire

        ChangeQuestionType string ->
            case questionnaire.newElement of
                Question record ->
                    { questionnaire
                        | newElement =
                            Question
                                { record | typ = string }
                    }

                Note record ->
                    questionnaire

        --open or close modals
        ViewOrClose modalType ->
            case modalType of
                TitleModal ->
                    { questionnaire | showTitleModal = not questionnaire.showTitleModal }

                ViewingTimeModal ->
                    { questionnaire | showViewingTimeModal = not questionnaire.showViewingTimeModal }

                EditTimeModal ->
                    { questionnaire | showEditTimeModal = not questionnaire.showEditTimeModal }

                NewNoteModal ->
                    let
                        changedQuestionnaire =
                            { questionnaire | showNewNoteModal = not questionnaire.showNewNoteModal }
                    in
                    if changedQuestionnaire.showNewNoteModal == True then
                        { changedQuestionnaire
                            | newElement =
                                Note
                                    { id = List.length questionnaire.elements
                                    , text = ""
                                    }
                        }

                    else
                        changedQuestionnaire

                QuestionModal ->
                    let
                        changedQuestionnaire =
                            { questionnaire | showNewQuestionModal = not questionnaire.showNewQuestionModal }
                    in
                    if changedQuestionnaire.showNewQuestionModal == True then
                        { changedQuestionnaire
                            | newElement =
                                Question
                                    { id = List.length questionnaire.elements
                                    , text = ""
                                    , antworten = []
                                    , hinweis = ""
                                    , typ = ""
                                    }
                        }

                    else
                        changedQuestionnaire

        --Other
        DeleteItem element ->
            { questionnaire | elements = deleteItemFrom element questionnaire.elements }

        -- validate inputs on submit and then save changes
        Submit ->
            if validate questionnaire == ValidationOK then
                { questionnaire
                    | validationResult = ValidationOK
                    , showViewingTimeModal = False
                    , showEditTimeModal = False
                    , editTime = questionnaire.inputEditTime
                    , viewingTimeBegin = questionnaire.inputViewingTimeBegin
                    , viewingTimeEnd = questionnaire.inputViewingTimeEnd
                }

            else
                { questionnaire
                    | validationResult = validate questionnaire
                    , inputViewingTimeBegin = ""
                    , inputViewingTimeEnd = ""
                    , inputEditTime = ""
                }

        SetNote ->
            if questionnaire.editMode == False then
                { questionnaire
                    | elements = append questionnaire.elements [ questionnaire.newElement ]
                    , showNewNoteModal = False
                }

            else
                { questionnaire
                    | elements = List.map (\e -> updateElement questionnaire.newElement e) questionnaire.elements
                    , showNewNoteModal = False
                    , editMode = False
                }

        SetQuestion ->
            if questionnaire.editMode == False then
                { questionnaire
                    | elements = append questionnaire.elements [ questionnaire.newElement ]
                    , showNewQuestionModal = False
                }

            else
                { questionnaire
                    | elements = List.map (\e -> updateElement questionnaire.newElement e) questionnaire.elements
                    , showNewQuestionModal = False
                    , editMode = False
                }

        EditQuestion element ->
            { questionnaire
                | newElement = element
                , showNewQuestionModal = True
                , editMode = True
            }

        EditNote element ->
            { questionnaire
                | newElement = element
                , showNewNoteModal = True
                , editMode = True
            }


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
    div []
        [ showHero questionnaire
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


showHero : Questionnaire -> Html Msg
showHero questionnaire =
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
        , a [ class "button", href "../index.html" ] [ text "Hauptmenü" ]
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
