module Main exposing (..)

import Browser exposing (sandbox)
import Html exposing (Html, button, br, div, footer, form, h1, header, i, input, p, section, text, table, td, th, tr)
import Html.Attributes exposing (class, id, maxlength, minlength, name, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import List exposing (append)
import Dialog

main =
  Browser.sandbox { init = initQuestionnaire, view = view, update = update }

--types
type Msg 
    = ChangeEditTime String
    | ChangeViewingTime_Begin String
    | ChangeViewingTime_End String
    | ViewOrClose_vtModal
    | ViewOrClose_etModal
    | ViewOrClose_noteModal
    | ChangeNote String
    | SetNote
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
    , typ : String }

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
    --new inputs
    , validationResult = NotDone
    , input_viewingTime_Begin = ""
    , input_viewingTime_End = ""
    , input_editTime = ""
    , newElement = initQuestion }

--Beispielfrage
initQuestion : FB_element
initQuestion = 
    Question    { id = 0, text = "Wie geht's?"
                , antworten = []
                , hinweis = "Das ist eine Question"
                , typ = "Typ 1" }


--Update logic
update : Msg -> Questionnaire -> Questionnaire
update msg questionnaire =
    case msg of
        ChangeEditTime newTime ->
            { questionnaire | input_editTime = newTime }
        ChangeViewingTime_Begin newTime ->
            { questionnaire | input_viewingTime_Begin = newTime }
        ChangeViewingTime_End newTime ->
            { questionnaire | input_viewingTime_End = newTime }
        ViewOrClose_vtModal ->
            if questionnaire.viewingTime_modal == False then { questionnaire | viewingTime_modal = True }
            else { questionnaire | viewingTime_modal = False }
        ViewOrClose_etModal ->
            if questionnaire.editTime_modal == False then { questionnaire | editTime_modal = True }
            else { questionnaire | editTime_modal = False }
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
        ViewOrClose_noteModal ->
            if questionnaire.newNote_modal == False then { questionnaire | newNote_modal = True }
            else { questionnaire | newNote_modal = False }
        SetNote ->
            { questionnaire     | elements = append questionnaire.elements [questionnaire.newElement]
                                , newNote_modal = False }
        ChangeNote string ->
            { questionnaire | newElement = Note { id = (List.length questionnaire.elements) + 1, text = string } }

        
        

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
        [ table [ class "table is-striped", style "width" "100%" ] (fragenTable questionnaire) 
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
        [ button [ style "margin-right" "10px" ] [ text "Neue Frage" ]
        , button [ onClick ViewOrClose_noteModal ] [ text "Neue Anmerkung"] 
        ]
    , viewEditTime_modal questionnaire
    , viewViewingTime_modal questionnaire
    , viewNewNote_modal questionnaire
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
    
--Table of Questions
fragenTable : Questionnaire -> List (Html Msg)
fragenTable questionnaire =
    append [ tableHead ] (List.indexedMap getTable questionnaire.elements)

tableHead : Html Msg
tableHead =
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

getTable : Int -> FB_element -> Html Msg
getTable index element =
    case element of
        Note a ->
            tr [ id (String.fromInt index) ]
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text a.text ]
                , td [] []
                , td [] []
                , td [] []
                ]

        Question f->
            tr [ id (String.fromInt index) ]
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text f.text ]
                , td [] [ text f.hinweis ]
                , td [] [ text f.typ ]
                , td [] [ i [   class "fas fa-cog"
                                , style "margin-right" "10px" ] []
                        , i [   class "fas fa-trash-alt" 
                                , onClick (DeleteItem element) ] [] 
                        ]
                ]

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
