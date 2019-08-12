module Edit exposing (..)

import Model exposing (..)
import Msg exposing (..)
import Html exposing (Html, a, br, button, div, footer, form, h1, header, i, input, label, nav, option, p, section, select, table, tbody, thead, td, text, th, tr)
import Html.Attributes exposing (class, href, id, maxlength, minlength, multiple, name, placeholder, selected, style, type_, value)
import Html.Events exposing (on, onClick, onInput)
import List exposing (append)
import Questionnaire exposing (..)
import QElement exposing (Q_element(..), getElementText, getQuestionHinweis, getQuestionTyp, getElementId, getAntworten)
import Answer exposing (Answer, getAnswerID, getAnswerType)
import Condition exposing (Condition)

showEditQuestionnaire : Model -> Html Msg
showEditQuestionnaire model =
    div []
        [ showHeroQuestionnaireTitle model.questionnaire
        , showQuestionList model.questionnaire
        , showTimes model.questionnaire
        , showCreateQuestionOrNoteButtons model.questionnaire
        , viewTitleModal model
        , viewEditTimeModal model
        , viewViewingTimeModal model
        , viewNewNoteModal model
        , viewNewQuestionModal model
        , viewNewAnswerModal model
        , viewConditions model.questionnaire
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


--MODALS


viewViewingTimeModal : Model -> Html Msg
viewViewingTimeModal model =
    let
        questionnaire = model.questionnaire
    in
        if model.showViewingTimeModal then
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
                                , value model.inputViewingTimeBegin
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
                                , value model.inputViewingTimeEnd
                                , maxlength 16
                                , minlength 16
                                , style "width" "180px"
                                , style "margin-left" "10px"
                                , onInput ChangeViewingTimeEnd
                                ]
                                []
                            ]
                        , br [] []
                        , viewValidation model
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

viewEditTimeModal : Model-> Html Msg
viewEditTimeModal model =
    let
        questionnaire = model.questionnaire
    in
        if model.showEditTimeModal then
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
                                , value model.inputEditTime
                                , maxlength 5
                                , minlength 5
                                , style "width" "180px"
                                , style "margin-left" "10px"
                                , style "margin-right" "10px"
                                , onInput ChangeEditTime
                                ]
                                []
                            , br [] []
                            , viewValidation model
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

viewTitleModal : Model -> Html Msg
viewTitleModal model =
    let
        questionnaire = model.questionnaire
    in
        if model.showTitleModal then
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
                                , value model.inputTitle
                                , onInput ChangeInputQuestionnaireTitle
                                ]
                                []
                            ]
                        ]
                    , footer [ class "modal-card-foot" ]
                        [ button
                            [ class "button is-success"
                            , onClick SetQuestionnaireTitle
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

viewNewNoteModal : Model -> Html Msg
viewNewNoteModal model =
    let 
        questionnaire = model.questionnaire
    in
        if model.showNewNoteModal then
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

viewNewQuestionModal : Model -> Html Msg
viewNewQuestionModal model =
    let 
        questionnaire = model.questionnaire 
    in
        if model.showNewQuestionModal then
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
                            , text "Zeit für Frage: "
                            ,br [] []
                            , input
                                [ class "input"
                                , type_ "text"
                                , value (model.inputQuestionTime)
                                , placeholder "HH:MM:SS"
                                , maxlength 8
                                , minlength 8
                                , style "width" "100%"
                                , onInput ChangeQuestionTime
                                ]
                                []
                            , br [] []
                            , viewQuestionValidation model.questionValidationResult
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
                                    (getQuestionOptions questionnaire.elements questionnaire.newCondition)
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

viewConditions : Questionnaire -> Html Msg
viewConditions questionnaire = 
    div[] (List.map (\c -> text ("("++String.fromInt c.parent_id++","++String.fromInt c.child_id++")")) questionnaire.conditions)




getQuestionOptions : List Q_element -> Condition -> List (Html Msg)
getQuestionOptions list newCondition =
    [ option [] [ text "Keine" ] ]
        ++ List.map (\e -> option [ selected (getElementId e == newCondition.parent_id) ] [ text ((String.fromInt (getElementId e)) ++"."++" "++getElementText e) ]) list


viewNewAnswerModal : Model-> Html Msg
viewNewAnswerModal model =
    let 
        questionnaire = model.questionnaire
    in
        if model.showNewAnswerModal then
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


viewValidation : Model -> Html msg
viewValidation model =
    let
        ( color, message ) =
            case model.validationResult of
                NotDone ->
                    ( "", "" )

                Error msg ->
                    ( "red", msg )

                ValidationOK ->
                    ( "green", "OK" )
    in
    div [ style "color" color ] [ text message ]

viewQuestionValidation : ValidationResult -> Html msg
viewQuestionValidation result =
    let
        ( color, message ) =
            case result of
                NotDone ->
                    ( "", "" )

                Error msg ->
                    ( "red", msg )

                ValidationOK ->
                    ( "green", "OK" )
    in
    div [ style "color" color ] [ text message ]

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