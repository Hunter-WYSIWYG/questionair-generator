module Main exposing (..)

import Browser exposing (sandbox)
import Html exposing (Html, button, br, div, footer, form, h1, header, i, input, label, p, section, text, table, td, th, tr)
import Html.Attributes exposing (class, id, maxlength, minlength, name, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import List exposing (append)
import Dialog

main =
  Browser.sandbox { init = initQuestionnaire, view = view, update = update }

--types
type Msg 
    --Changing Input
    = ChangeEditTime String
    | ChangeViewingTime_Begin String
    | ChangeViewingTime_End String
    | ChangeNote String
    | ChangeQuestion_text String
    | ChangeQuestion_newAwnser Answer
    | ChangeQuestion_note String
    | ChangeQuestion_typ String 
    --Modals
    | ViewOrClose_vtModal
    | ViewOrClose_etModal
    | ViewOrClose_noteModal
    | ViewOrClose_questionModal
    --Other
    | SetNote
    | SetQuestion
    | EditQuestion FB_element
    | EditNote FB_element
    | DeleteItem FB_element
    | Submit

type alias Questionnaire = 
    { elements : List FB_element
    --times
    , viewingTime_Begin : String
    , viewingTime_End : String
    , editTime : String
    --modals
    , editTime_modal : Bool
    , viewingTime_modal : Bool
    , newNote_modal : Bool
    , newQuestion_modal : Bool
    --newInputs
    , validationResult : ValidationResult
    , input_editTime : String
    , input_viewingTime_Begin : String
    , input_viewingTime_End : String
    , newElement : FB_element }

type FB_element 
    = Note  { id : Int
            , text : String }

    | Question  { id : Int 
                , text : String
                , antworten : List Answer
                , hinweis : String
                , typ : String }

type alias Answer = 
    { id : Int
    , text : String
    --, typ : String 
    }

type ValidationResult
    = NotDone
    | Error String
    | ValidationOK

--Init
initQuestionnaire : Questionnaire 
initQuestionnaire = 
    { elements = [initQuestion]
    --times
    , viewingTime_Begin = ""
    , viewingTime_End = ""
    , editTime = ""
    --modals
    , viewingTime_modal = False
    , editTime_modal = False
    , newNote_modal = False
    , newQuestion_modal = False
    --new inputs
    , validationResult = NotDone
    , input_viewingTime_Begin = ""
    , input_viewingTime_End = ""
    , input_editTime = ""
    , newElement = initQuestion }

--Beispielfrage
initQuestion : FB_element
initQuestion = 
    Question    { id = 0
                , text = "Wie geht's?"
                , antworten = []
                , hinweis = "Das ist eine Frage"
                , typ = "Single Choice" }


--Update logic
update : Msg -> Questionnaire -> Questionnaire
update msg questionnaire =
    case msg of
        --changing input
        ChangeEditTime newTime ->
            { questionnaire | input_editTime = newTime }
        ChangeViewingTime_Begin newTime ->
            { questionnaire | input_viewingTime_Begin = newTime }
        ChangeViewingTime_End newTime ->
            { questionnaire | input_viewingTime_End = newTime }
        ChangeNote string ->
            { questionnaire | newElement = Note { id = (List.length questionnaire.elements), text = string } }
        ChangeQuestion_text string -> 
            case questionnaire.newElement of
                Question record -> 
                    { questionnaire | newElement = Question     { id = record.id
                                                                , text = string
                                                                , antworten = record.antworten
                                                                , hinweis = record.hinweis
                                                                , typ = record.typ} }
                Note record ->
                    questionnaire
        ChangeQuestion_newAwnser newAnswer -> 
            case questionnaire.newElement of
                Question record -> 
                    { questionnaire | newElement = Question     { id = record.id
                                                                , text = record.text
                                                                , antworten = record.antworten ++ [ newAnswer ]
                                                                , hinweis = record.hinweis
                                                                , typ = record.typ} }
                Note record ->
                    questionnaire
        ChangeQuestion_note string -> 
            case questionnaire.newElement of
                Question record -> 
                    { questionnaire | newElement = Question     { id = record.id
                                                                , text = record.text
                                                                , antworten = record.antworten
                                                                , hinweis = string
                                                                , typ = record.typ} }
                Note record ->
                    questionnaire
        ChangeQuestion_typ string -> 
            case questionnaire.newElement of
                Question record -> 
                    { questionnaire | newElement = Question     { id = record.id
                                                                , text = record.text
                                                                , antworten = record.antworten
                                                                , hinweis = record.hinweis
                                                                , typ = string } }
                Note record ->
                    questionnaire
        --modals
        ViewOrClose_vtModal ->
            if questionnaire.viewingTime_modal == False then { questionnaire | viewingTime_modal = True }
            else { questionnaire | viewingTime_modal = False }
        ViewOrClose_etModal ->
            if questionnaire.editTime_modal == False then { questionnaire | editTime_modal = True }
            else { questionnaire | editTime_modal = False }
        ViewOrClose_noteModal ->
            if questionnaire.newNote_modal == False then    { questionnaire | newNote_modal = True 
                                                            , newElement = Note     { id = (List.length questionnaire.elements)
                                                                                    , text = "" } }
            else { questionnaire | newNote_modal = False }
        ViewOrClose_questionModal ->
            if questionnaire.newQuestion_modal == False then    { questionnaire | newQuestion_modal = True
                                                                , newElement = Question  { id = (List.length questionnaire.elements)
                                                                                         , text = "" 
                                                                                         , antworten = []
                                                                                         , hinweis = ""
                                                                                         , typ = ""} 
                                                                }
            else { questionnaire | newQuestion_modal = False }
        --Other
        DeleteItem element ->
            { questionnaire | elements = (deleteItemFrom element questionnaire.elements) }
        Submit ->
            if (validate questionnaire) == ValidationOK 
            then { questionnaire    | validationResult = validate questionnaire
                                    , viewingTime_modal = False
                                    , editTime_modal = False
                                    , editTime = questionnaire.input_editTime
                                    , viewingTime_Begin = questionnaire.input_viewingTime_Begin
                                    , viewingTime_End = questionnaire.input_viewingTime_End}
            else { questionnaire | validationResult = validate questionnaire }
        SetNote ->
            { questionnaire     | elements = append questionnaire.elements [questionnaire.newElement]
                                , newNote_modal = False }
        SetQuestion -> 
            { questionnaire     | elements = append questionnaire.elements [questionnaire.newElement]
                                , newQuestion_modal = False }
        EditQuestion element ->
            { questionnaire     | newElement = element
                                , newQuestion_modal = True }
        EditNote element ->
            { questionnaire     | newElement = element
                                , newNote_modal = True }
        


deleteItemFrom : FB_element -> List FB_element -> List FB_element
deleteItemFrom element list =
    Tuple.first (List.partition (\e -> e /= element) list) 

validate : Questionnaire -> ValidationResult
validate questionnaire =
    if ((String.length questionnaire.input_editTime) /= 5
        && (String.length questionnaire.input_editTime) /= 0) then
        Error "Die Bearbeitungszeit muss das Format HH:MM haben"
    else if ((String.length questionnaire.input_viewingTime_Begin) == 0 
            && (String.length questionnaire.viewingTime_End) == 0) then
        ValidationOK
    else if ((String.length questionnaire.input_viewingTime_Begin) /= 16 
            || (String.length questionnaire.viewingTime_End) /= 16) then
        Error "Die Zeiten müssen das Format DD:MM:YYYY:HH:MM haben"
    else
        ValidationOK

getText_newElement : FB_element -> String
getText_newElement element =
    case element of
        Question record -> record.text
        Note record -> record.text

--Better alternative?
getHinweis_newElement : FB_element -> String
getHinweis_newElement element =
    case element of
        Question record -> record.hinweis
        Note record -> "None"

getTyp_newElement : FB_element -> String
getTyp_newElement element =
    case element of
        Question record -> record.typ
        Note record -> "None"

--View

view : Questionnaire -> Html Msg
view questionnaire =
  div []
    [ section [ class "hero is-primary" ]
        [ div [ class "hero-body" ]
            [
                div [ class "container is-fluid" ]
                    [ h1 [ class "title" ] [ text "Fragebogen" ]
                    ]
            ]
        ]
    , div [ class "container is-fluid", style "margin-bottom" "10px" ] 
        [ table [ class "table is-striped", style "width" "100%" ] (questionsTable questionnaire) 
        ]
    , div [ class "container is-fluid", style "margin-bottom" "10px"]
        [ text ("Bearbeitungszeit: " ++ (getViewingTime questionnaire))
        , i     [ class "fas fa-cog"
                , style "margin-left" "10px"
                , onClick ViewOrClose_etModal ] []
        , br [] []
        , text ("Erscheinungszeit: " ++ (getEditTime questionnaire))
        , i     [ class "fas fa-cog"
                , style "margin-left" "10px"
                , onClick ViewOrClose_vtModal ] []
        ]
    , div [ class "container is-fluid" ]
        [ button    [ style "margin-right" "10px" 
                    , onClick ViewOrClose_questionModal ] 
                        [ text "Neue Frage" ]
        , button    [ onClick ViewOrClose_noteModal ] 
                        [ text "Neue Anmerkung"] 
        ]
    , viewEditTime_modal questionnaire
    , viewViewingTime_modal questionnaire
    , viewNewNote_modal questionnaire
    , viewNewQuestion_modal questionnaire
    ]

getViewingTime : Questionnaire -> String
getViewingTime questionnaire =
    if (questionnaire.editTime == "") then "unbegrenzt"
    else questionnaire.editTime

getEditTime : Questionnaire -> String
getEditTime questionnaire =
    if (questionnaire.viewingTime_Begin == "") then "unbegrenzt"
    else ("Von " ++ questionnaire.viewingTime_Begin ++ " Bis " ++ questionnaire.viewingTime_End)

--Modals
viewViewingTime_modal : Questionnaire -> Html Msg
viewViewingTime_modal questionnaire = 
    if questionnaire.viewingTime_modal then
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
                            , value questionnaire.input_viewingTime_Begin
                            , maxlength 16
                            , minlength 16
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , style "margin-right" "10px"
                            , onInput ChangeViewingTime_Begin ] []
                        , text " Bis "
                        , input 
                            [ class "input"
                            , type_ "text"
                            , placeholder "DD:MM:YYYY:HH:MM"
                            , value questionnaire.input_viewingTime_End
                            , maxlength 16
                            , minlength 16
                            , style "width" "180px"
                            , style "margin-left" "10px" 
                            , onInput ChangeViewingTime_End ] []
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button    [ class "button is-success"
                                , onClick Submit ]  [ text "Übernehmen" ] ]
                ]
            , button    [ class "modal-close is-large"
                        , onClick ViewOrClose_vtModal ] [] 
            ]
    else 
        div [] []

viewEditTime_modal : Questionnaire -> Html Msg
viewEditTime_modal questionnaire = 
    if questionnaire.editTime_modal then
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
                            , value questionnaire.input_editTime
                            , maxlength 5
                            , minlength 5
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , style "margin-right" "10px"
                            , onInput ChangeEditTime ] 
                            []
                        , br [] []
                        , viewValidation questionnaire
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button    [ class "button is-success"
                                , onClick Submit]  [ text "Übernehmen" ] ]
                ]
            , button    [ class "modal-close is-large" 
                        , onClick ViewOrClose_etModal ] [] 
            ]
    else 
        div [] []
        
viewNewNote_modal : Questionnaire -> Html Msg
viewNewNote_modal questionnaire =
    if questionnaire.newNote_modal then
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
                            , value (getText_newElement questionnaire.newElement)
                            , onInput ChangeNote ] 
                            []
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button    [ class "button is-success"
                                , onClick SetNote]  [ text "Übernehmen" ] ]
                ]
            , button    [ class "modal-close is-large" 
                        , onClick ViewOrClose_noteModal ] [] 
            ]
    else 
        div [] []
    
viewNewQuestion_modal : Questionnaire -> Html Msg
viewNewQuestion_modal questionnaire =
    if questionnaire.newQuestion_modal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head" ]
                    [ p [ class "modal-card-title" ] [ text "Neue Frage" ] ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ table [ class "table is-striped", style "width" "100%" ] (answersTable questionnaire)
                        , br [] []
                        , button    [ style "margin-bottom" "10px" ] [ text "Neue Antwort" ]
                        , br [] []
                        , text "Fragetext: "
                        , input 
                            [ class "input"
                            , type_ "text"
                            , style "width" "100%"
                            , value (getText_newElement questionnaire.newElement)
                            , onInput ChangeQuestion_text] 
                            []
                        , br [] []
                        , text "Hinweis: "
                        , input 
                            [ class "input"
                            , type_ "text"
                            , style "width" "100%"
                            , value (getHinweis_newElement questionnaire.newElement)
                            , onInput ChangeQuestion_note ] 
                            []
                        , br [] []
                        , text ("Typ: " ++ (getTyp_newElement questionnaire.newElement) ) 
                        , br [] []
                        , radio "Single Choice" (ChangeQuestion_typ "Single Choice")
                        , radio "Multiple Choice" (ChangeQuestion_typ "Multiple Choice") 
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button    [ class "button is-success"
                                , onClick SetQuestion ]  [ text "Übernehmen" ] ]
                ]
            , button    [ class "modal-close is-large" 
                        , onClick ViewOrClose_questionModal ] [] 
            ]
    else 
        div [] []

--Table of Questions
questionsTable : Questionnaire -> List (Html Msg)
questionsTable questionnaire =
    append [ tableHead_questions ] (List.indexedMap getQuestionTable questionnaire.elements)

tableHead_questions : Html Msg
tableHead_questions =
    tr [] [ 
        th [] [ 
            text "ID" 
        ], 
        th [] [ 
            text "Fragetext" 
        ], 
        th [] [ 
            text "Hinweis" 
        ],
        th [] [
            text "Typ"
        ],
        th [] [
            text "Aktion"
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
                , td [] [ i [   class "fas fa-cog"
                                , style "margin-right" "10px"
                                , onClick (EditNote element) ] []
                        , i [   class "fas fa-trash-alt" 
                                , onClick (DeleteItem element) ] [] 
                        ]
                ]

        Question f->
            tr [ id (String.fromInt index) ]
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text f.text ]
                , td [] [ text f.hinweis ]
                , td [] [ text f.typ ]
                , td [] [ i [   class "fas fa-cog"
                                , style "margin-right" "10px"
                                , onClick (EditQuestion element) ] []
                        , i [   class "fas fa-trash-alt" 
                                , onClick (DeleteItem element) ] [] 
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
    tr [] [ 
        th [] [ 
            text "ID" 
        ], 
        th [] [ 
            text "Text" 
        ],
        th [] [
            text "Aktion"
        ]
    ]

getAnswerTable : Int -> Answer -> Html Msg
getAnswerTable index element =
    tr [ id (String.fromInt index) ]
        [ td [] [ text (String.fromInt index) ]
        , td [] [ text element.text ]
        , td [] [ i [   class "fas fa-cog"
                , style "margin-right" "10px" ] []
                , i [   class "fas fa-trash-alt" ] [] 
        ]
    ]

--Error Message for viewTime and editTime modals
viewValidation : Questionnaire -> Html msg
viewValidation questionnaire =
    let
        (color, message) =
            case questionnaire.validationResult of
                NotDone -> ("", "")
                Error msg -> ("red", msg)
                ValidationOK -> ("green", "OK")
    in
        div [ style "color" color ] [ text message ]

--radio control
radio : String -> msg -> Html msg
radio value msg =
    label
        [ style "padding" "20px" ]
        [ input [ type_ "radio"
                , name "font-size"
                , onClick msg ] []
        , text value ]
