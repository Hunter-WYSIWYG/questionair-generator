module Main exposing (..)

import Browser exposing (sandbox)
import Html exposing (Html, button, br, div, footer, form, h1, header, input, p, section, text, table, td, th, tr)
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

type alias Questionnaire = 
    { elements : List FB_element
    , viewingTime_Begin : String
    , viewingTime_End : String
    , editTime : String
    , editTime_modal : Bool
    , viewingTime_modal : Bool }

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

--Init
initQuestionnaire : Questionnaire 
initQuestionnaire = 
    { elements = [initQuestion]
    , viewingTime_Begin = "01.01.2019:09:00"
    , viewingTime_End = "01:01:2019:12:00"
    , editTime = ""
    , viewingTime_modal = False
    , editTime_modal = False }

--Beispielfrage
initQuestion : FB_element
initQuestion = 
    Question    { id = 0, text = "Wie geht's?"
                , antworten = [], hinweis = "Das ist eine Question"
                , typ = "Typ 1"}


--Update logic
update : Msg -> Questionnaire -> Questionnaire
update msg questionnaire =
    case msg of
        ChangeEditTime newTime ->
            questionnaire
        ChangeViewingTime_Begin newTime ->
            questionnaire
        ChangeViewingTime_End newTime ->
            questionnaire
        ViewOrClose_vtModal ->
            if questionnaire.viewingTime_modal == False then { questionnaire | viewingTime_modal = True }
            else { questionnaire | viewingTime_modal = False }


--View

view : Questionnaire -> Html Msg
view questionnaire =
  div []
    [ section [ class "hero is-primary" ]
        [ div [ class "hero-body" ]
            [
                div [ class "container" ]
                    [ h1 [ class "title" ] [ text "Questionnaire" ]
                    ]
            ]
        ]
    , div [ class "container is-fluid", style "margin-bottom" "10px" ] 
        [ table [ class "table is-striped", style "width" "100%" ] (fragenTable questionnaire) 
        ]
    , div [ class "container is-fluid", style "margin-bottom" "10px"]
        [ text ("Bearbeitungszeit: " ++ (getViewingTime questionnaire))
        , button [ style "margin-left" "10px" ] [ text "B" ]
        --, input [ class "input", type_ "text", placeholder "HH:MM", maxlength 5, style "width" "150px", style "margin-left" "10px", style "margin-bottom" "10px" ] []
        , br [] []
        --, text ("Erscheinungszeit: Von " ++ questionnaire.viewingTime_Begin)
        --, 
        --, text (" Bis " ++ questionnaire.viewingTime_End) 
        --, input [ class "input", type_ "text", placeholder "DD:MM:YYYY:HH:MM", value questionnaire.viewingTime_End, maxlength 16, minlength 16, style "width" "180px", style "margin-left" "10px" ] []
        , text ("Erscheinungszeit: " ++ (getEditTime questionnaire))
        , button [ style "margin-left" "10px", onClick ViewOrClose_vtModal ] [ text "B" ]
        ]
    , div [ class "container" ]
        [ button [ style "margin-right" "10px" ] [ text "Neue Frage" ]
        , button [] [ text "Neue Anmerkung"] 
        ]
    , viewEditTime_modal questionnaire
    ]

getViewingTime : Questionnaire -> String
getViewingTime questionnaire =
    if (questionnaire.editTime == "") then "unbegrenzt"
    else questionnaire.editTime

getEditTime : Questionnaire -> String
getEditTime questionnaire =
    if (questionnaire.viewingTime_Begin == "") then "unbegrenzt"
    else ("Von " ++ questionnaire.viewingTime_Begin ++ " Bis " ++ questionnaire.viewingTime_End)

viewEditTime_modal : Questionnaire -> Html Msg
viewEditTime_modal questionnaire = 
    if questionnaire.viewingTime_modal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head" ]
                    [ p [ class "modal-card-title" ] [ text "Erscheinungszeit" ] ]
                , section [ class "modal-card-body" ]
                    [ div [ class "container is-fluid" ]
                        [ text "Von "
                        , input 
                            [ class "input"
                            , type_ "text"
                            , placeholder "DD:MM:YYYY:HH:MM"
                            , value questionnaire.viewingTime_Begin
                            , maxlength 16
                            , minlength 16
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , style "margin-right" "10px" ] 
                            []
                        , text " Bis "
                        , input 
                            [ class "input"
                            , type_ "text"
                            , placeholder "DD:MM:YYYY:HH:MM"
                            , value questionnaire.viewingTime_End
                            , maxlength 16
                            , minlength 16
                            , style "width" "180px"
                            , style "margin-left" "10px" ] 
                            [] 
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button [ class "button is-success" ] [ text "Hinzufügen" ] ]
                ]
            , button [ class "modal-close is-large", onClick ViewOrClose_vtModal ] [] 
            ]
    else 
        div [] []
        

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

getTable : Int -> FB_element -> Html msg
getTable index element =
    case element of
        Note a ->
            tr [ id (String.fromInt index) ]
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text a.text ]
                ]

        Question f->
            tr [ id (String.fromInt index) ]
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text f.text ]
                , td [] [ text f.hinweis ]
                , td [] [ text f.typ ]
                , td [] [ button [ style "margin-right" "10px" ] [ text "B" ]
                        , button [] [ text "L" ] ]
                ]

