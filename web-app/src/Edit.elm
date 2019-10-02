module Edit exposing (answersTable, getAnswerTable, getQuestionOptions, getQuestionTable, questionsTable, radio, showCreateQuestionOrNoteButtons, showEditQuestionnaire, showHeroQuestionnaireTitle, showInputBipolarUnipolar, showQuestionList, showTimes, tableHead_answers, tableHead_questions, viewConditions, viewEditTimeModal, viewNewAnswerModal, viewNewNoteModal, viewNewQuestionModal, viewQuestionValidation, viewTitleModal, viewValidation, viewViewingTimeModal)

{-| Enthält die View für das Bearbeiten von Fragebögen.


# Öffentliche Funktionen

@docs answersTable, getAnswerTable, getQuestionOptions, getQuestionTable, questionsTable, radio, showCreateQuestionOrNoteButtons, showEditQuestionnaire, showHeroQuestionnaireTitle, showInputBipolarUnipolar, showQuestionList, showTimes, tableHead_answers, tableHead_questions, viewConditions, viewEditTimeModal, viewNewAnswerModal, viewNewNoteModal, viewNewQuestionModal, viewQuestionValidation, viewTitleModal, viewValidation, viewViewingTimeModal

-}

import Answer exposing (Answer)
import Condition exposing (Condition)
import Html exposing (Html, a, br, button, div, footer, h1, header, i, input, label, option, p, section, select, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, id, maxlength, minlength, multiple, name, placeholder, selected, style, type_, value)
import Html.Events exposing (onClick, onInput)
import List
import Model exposing (ModalType(..), Model, Msg(..), ValidationResult(..))
import QElement exposing (Q_element(..))
import Questionnaire exposing (Questionnaire)
import DateTimePicker exposing (..)
import Html.Styled
import Html.Styled.Attributes



{-| Zeigt die Oberfläche bzw. die View für das Bearbeiten von Fragebögen an.
-}
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
        , viewNewConditionModal1 model
        , viewNewConditionModal2 model
        ]


{-| Zeigt den Titel des Fragebogens in einem Hero (s. Bulma.io) an.
-}
showHeroQuestionnaireTitle : Questionnaire -> Html Msg
showHeroQuestionnaireTitle questionnaire =
    section [ class "hero is-info" ]
        [ div [ class "hero-body" ]
            [ div [ class "container is-fluid" ]
                [ h1 [ class "title" ]
                    [ text questionnaire.title
                    , i
                        [ class "fas fa-cog symbol"
                        , style "margin-left" "10px"
                        , onClick (ViewOrClose TitleModal)
                        ]
                        []
                    ]
                ]
            ]
        ]


{-| Zeigt eine Tabelle mit den Fragen und Anmerkungen des Fragebogens an.
-}
showQuestionList : Questionnaire -> Html Msg
showQuestionList questionnaire =
    div [ class "box container is-fluid questionList", style "flex-basis" "80%", style "overflow-y" "auto", style "height" "60vh", style "margin-top" "2em", style "margin-bottom" "2em" ]
        [ table
            [ class "table is-striped"
            ]
            [ thead
                []
                [ tableHead_questions
                ]
            , tbody
                []
                (questionsTable questionnaire)
            ]
        ]


{-| Zeigt die Zeiten (Bearbeitungszeiten, Erscheinungszeiten, usw.) an.
-}
showTimes : Questionnaire -> Html Msg
showTimes questionnaire =
    div [ class "container is-fluid", style "margin-bottom" "10px" ]
        [ text ("Bearbeitungszeit: " ++ Questionnaire.getViewingTime questionnaire)
        , i
            [ class "fas fa-cog symbol"
            , style "margin-left" "10px"
            , onClick (ViewOrClose EditTimeModal)
            ]
            []
        , br [] []
        , text ("Erscheinungszeit: " ++ Questionnaire.getEditTime questionnaire)
        , i
            [ class "fas fa-cog symbol"
            , style "margin-left" "10px"
            , onClick (ViewOrClose ViewingTimeModal)
            ]
            []
        ]


{-| Zeigt die Buttons für das Erstellen von neuen Elementen (Fragen, Anmerkungen) für den Fragebogen an.
-}
showCreateQuestionOrNoteButtons : Questionnaire -> Html Msg
showCreateQuestionOrNoteButtons questionnaire =
    div [ class "container is-fluid divButtons" ]
        [ button
            [ class "qnButton"
            , style "margin-right" "10px"
            , onClick (ViewOrClose QuestionModal)
            ]
            [ text "Neue Frage" ]
        , button
            [ class "qnButton"
            , style "margin-right" "10px"
            , onClick (ViewOrClose NewNoteModal)
            ]
            [ text "Neue Anmerkung" ]
        , button [ class "qnButton", onClick (ViewOrClose ConditionModal1) ]
            [ text "Bedingungen" ]
        , br [] []
        , br [] []
        , button [ class "qnButton", onClick DownloadQuestionnaire ] [ text "Download" ]
        ]


{-| Zeigt das Modal zum Bearbeiten der Erscheinungszeiten an.
-}
viewViewingTimeModal : Model -> Html Msg
viewViewingTimeModal model =
    let
        questionnaire =
            model.questionnaire
    in
    if model.showViewingTimeModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head mediumlightblue" ]
                    [ p [ class "modal-card-title is-size-3 has-text-centered is-italic" ] [ text "Erscheinungszeit" ]
                    , button [ class "is-large delete", onClick (ViewOrClose ViewingTimeModal) ] []
                    ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "Von "
                        , input
                            [ class "input is-medium"
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
                            , Html.Styled.toUnstyled (DateTimePicker.dateTimePicker
                                DateTimePickerChanged
                                [ Html.Styled.Attributes.class "my-datetimepicker" ]
                                model.state
                                model.value)
                        , text " Bis "
                        , input
                            [ class "input is-medium"
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
                            , Html.Styled.toUnstyled (DateTimePicker.dateTimePicker
                                DateTimePickerChanged
                                [ Html.Styled.Attributes.class "my-datetimepicker" ]
                                model.state
                                model.value)
                        ]
                    , br [] []
                    , viewValidation model
                    ]
                , footer [ class "modal-card-foot mediumlightblue" ]
                    [ button
                        [ class "qnButton"
                        , onClick Submit
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            ]

    else
        div [] []


{-| Zeigt das Modal für das Bearbeiten der Bearbeitungszeit des Fragebogens an.
-}
viewEditTimeModal : Model -> Html Msg
viewEditTimeModal model =
    let
        questionnaire =
            model.questionnaire
    in
    if model.showEditTimeModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head mediumlightblue" ]
                    [ p [ class "modal-card-title is-size-3 has-text-centered is-italic" ] [ text "Bearbeitungszeit" ]
                    , button [ class "is-large delete", onClick (ViewOrClose EditTimeModal) ] []
                    ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "Zeit: "
                        , input
                            [ class "input is-medium"
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
                            , Html.Styled.toUnstyled (DateTimePicker.timePicker
                                DateTimePickerChanged
                                [ Html.Styled.Attributes.class "my-timepicker" ]
                                model.state
                                model.value)
                        , br [] []
                        , viewValidation model
                        ]
                    ]
                , footer [ class "modal-card-foot mediumlightblue" ]
                    [ button
                        [ class "qnButton"
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


{-| Zeigt das Modal für das Bearbeiten des Fragebogentitels an.
-}
viewTitleModal : Model -> Html Msg
viewTitleModal model =
    let
        questionnaire =
            model.questionnaire
    in
    if model.showTitleModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head mediumlightblue" ]
                    [ p [ class "modal-card-title is-size-3 has-text-centered is-italic" ] [ text "Titel ändern" ]
                    , button [ class "is-large delete", onClick (ViewOrClose TitleModal) ] []
                    ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "Text: "
                        , input
                            [ class "input is-medium"
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
                , footer [ class "modal-card-foot mediumlightblue" ]
                    [ button
                        [ class "button is-success"
                        , onClick SetQuestionnaireTitle
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            ]

    else
        div [] []


{-| Zeigt das Modal für das Erstellen einer Anmerkung an.
-}
viewNewNoteModal : Model -> Html Msg
viewNewNoteModal model =
    let
        questionnaire =
            model.questionnaire
    in
    if model.showNewNoteModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head mediumlightblue" ]
                    [ p [ class "modal-card-title is-size-3 has-text-centered is-italic" ] [ text "Neue Anmerkung" ]
                    , button [ class "is-large delete", onClick (ViewOrClose NewNoteModal) ] []
                    ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "Text: "
                        , input
                            [ class "input is-medium"
                            , type_ "text"
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , style "margin-right" "10px"
                            , value (QElement.getElementText questionnaire.newElement)
                            , onInput ChangeQuestionOrNoteText
                            ]
                            []
                        ]
                    ]
                , footer [ class "modal-card-foot mediumlightblue" ]
                    [ button
                        [ class "qnButton"
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


{-| Zeigt das Modal für das Erstellen einer neuen Frage an.
-}
viewNewQuestionModal : Model -> Html Msg
viewNewQuestionModal model =
    if model.showNewQuestionModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head mediumlightblue" ]
                    [ p [ class "modal-card-title is-size-3 has-text-centered is-italic" ] [ text "Neue Frage" ]
                    , button [ class "is-large delete", onClick (ViewOrClose QuestionModal) ] []
                    ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ table [ class "table is-striped", style "width" "100%" ] (answersTable model.questionnaire)
                        , br [] []
                        , button [ class "qnButton", style "margin-bottom" "10px", onClick (ViewOrClose AnswerModal) ] [ text "Neue Antwort" ]
                        , br [] []
                        , showInputBipolarUnipolar model.questionnaire
                        , br [ style "margin-top" "20px" ] []
                        , text "Fragetext: "
                        , input
                            [ class "input is-medium"
                            , type_ "text"
                            , style "width" "100%"
                            , value (QElement.getElementText model.questionnaire.newElement)
                            , onInput ChangeQuestionOrNoteText
                            ]
                            []
                        , br [ style "margin-top" "20px" ] []
                        , text "Hinweis: "
                        , input
                            [ class "input is-medium"
                            , type_ "text"
                            , style "width" "100%"
                            , value (QElement.getQuestionHinweis model.questionnaire.newElement)
                            , onInput ChangeQuestionNote
                            ]
                            []
                        , br [] []
                        , text ("Typ: " ++ QElement.getQuestionTyp model.questionnaire.newElement)
                        , br [] []
                        , radio "Single Choice" (ChangeQuestionType "Single Choice")
                        , radio "Multiple Choice" (ChangeQuestionType "Multiple Choice")
                        , radio "Ja/Nein Frage" (ChangeQuestionType "Ja/Nein Frage")
                        , radio "Skaliert unipolar" (ChangeQuestionType "Skaliert unipolar")
                        , radio "Skaliert bipolar" (ChangeQuestionType "Skaliert bipolar")
                        , br [] []
                        ]
                    ]
                , footer [ class "modal-card-foot mediumlightblue" ]
                    [ button
                        [ class "qnButton"
                        , onClick SetQuestion
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            ]

    else
        div [] []


{-| TODO: !!!NUR FÜR DEBUG ZWECKE!!!
Zeigt eine Liste von Bedingungen an.
-}
viewConditions : Questionnaire -> Html Msg
viewConditions questionnaire =
    div [] (List.map (\c -> text ("(" ++ String.fromInt c.parent_id ++ "," ++ String.fromInt c.child_id ++ ")")) questionnaire.conditions)


{-| Zeigt eine Liste von Fragen an, die zur Bedingung als "Elternfrage" oder "Kindfrage" hinzugefügt werden können.
Siehe viewConditionModal
-}
getQuestionOptions : List Q_element -> Condition -> List (Html Msg)
getQuestionOptions list newCondition =
    [ option [] [ text "Keine" ] ]
        ++ List.map (\e -> option [ selected (QElement.getElementId e == newCondition.parent_id) ] [ text (String.fromInt (QElement.getElementId e) ++ "." ++ " " ++ QElement.getElementText e) ]) list


{-| Zeigt ein Modal zum Erstellen neuer Antworten an.
-}
viewNewAnswerModal : Model -> Html Msg
viewNewAnswerModal model =
    let
        questionnaire =
            model.questionnaire
    in
    if model.showNewAnswerModal then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head mediumlightblue" ]
                    [ p [ class "modal-card-title is-size-3 has-text-centered is-italic" ] [ text "Neue Antwort" ]
                    , button [ class "is-large delete", onClick (ViewOrClose AnswerModal) ] []
                    ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "Antworttext: "
                        , input
                            [ class "input is-medium"
                            , type_ "text"
                            , style "width" "100%"
                            , onInput ChangeAnswerText
                            ]
                            []
                        ]
                    , br [] []
                    , div []
                        [ text ("Typ: " ++ questionnaire.newAnswer.typ)
                        , br [] []
                        , radio "Fester Wert" (ChangeAnswerType "regular")
                        , radio "Freie Eingabe" (ChangeAnswerType "free")
                        ]
                    ]
                , footer [ class "modal-card-foot mediumlightblue" ]
                    [ button
                        [ class "qnButton"
                        , onClick SetAnswer
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            ]

    else
        div [] []


{-| TODO: AUSSAGEKRÄFTIGERE NAMEN!
Zeigt ein Modal mit einer Tabelle mit vorhandenen Bedingungen an.
-}
viewNewConditionModal1 : Model -> Html Msg
viewNewConditionModal1 model =
    if model.showNewConditionModal1 then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head mediumlightblue" ]
                    [ p [ class "modal-card-title is-size-3 has-text-centered is-italic" ] [ text "Bedingungen" ]
                    , button [ class "is-large delete", onClick (ViewOrClose ConditionModal1) ] []
                    ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ table [ class "table is-striped", style "width" "100%" ] (conditionsTable model.questionnaire)
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button
                        [ class "qnButton"
                        , onClick (ViewOrClose ConditionModal2)
                        ]
                        [ text "Neu" ]
                    ]
                ]
            ]

    else
        div [] []


{-| TODO: AUSSAGEKRÄFTIGERE NAMEN!
Zeigt ein Modal zur Erstellung von Bedingungen an.
-}
viewNewConditionModal2 : Model -> Html Msg
viewNewConditionModal2 model =
    if model.showNewConditionModal2 then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head mediumlightblue" ]
                    [ p [ class "modal-card-title is-size-3 has-text-centered is-italic" ] [ text "Bedingungen" ]
                    , button [ class "is-large delete", onClick (ViewOrClose ConditionModal2) ] []
                    ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "von Frage: "
                        , br [] []
                        , div [ class "select" ]
                            [ select [ onInput ChangeInputParentId ]
                                (getQuestionOptions model.questionnaire.elements model.questionnaire.newCondition)
                            ]
                        , br [] []
                        , text " zu Frage: "
                        , br [] []
                        , div [ class "select" ]
                            [ select [ onInput ChangeInputChildId ]
                                (getQuestionOptions model.questionnaire.elements model.questionnaire.newCondition)
                            ]
                        , br [] []
                        , text "Bei Beantwortung der Antworten mit den IDs: "

                        --, text (Debug.toString (List.map getID model.questionnaire.newCondition.answers))
                        , br [] []
                        , input
                            [ placeholder "Hier ID eingeben"
                            , onInput AddAnswerToNewCondition
                            ]
                            []
                        , button
                            [ class "button"
                            , style "margin-left" "1em"
                            , style "margin-top" "0.25em"
                            , onClick AddConditionAnswer
                            ]
                            [ text "Hinzufügen" ]
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button
                        [ class "qnButton"
                        , onClick SetConditions
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            ]

    else
        div [] []


{-| Zeigt eine Tabelle mit vorhandenen Fragen an.
-}
questionsTable : Questionnaire -> List (Html Msg)
questionsTable questionnaire =
    List.indexedMap getQuestionTable questionnaire.elements


{-| Der Tabellenkopf der Tabelle mit den vorhandenen Fragen.
-}
tableHead_questions : Html Msg
tableHead_questions =
    tr []
        [ th [ style "width" "5%" ]
            [ text "ID"
            ]
        , th [ style "width" "40%" ]
            [ text "Fragetext"
            ]
        , th [ style "width" "25%" ]
            [ text "Hinweis"
            ]
        , th [ style "width" "20%" ]
            [ text "Typ"
            ]
        , th [ style "width" "10%" ]
            [ text "Aktion"
            ]
        ]


{-| Die Darstellung eines Elements des Fragebogens in der Tabelle.
-}
getQuestionTable : Int -> Q_element -> Html Msg
getQuestionTable index element =
    case element of
        Note a ->
            tr [ id (String.fromInt index) ]
                [ td [ style "width" "5%" ] [ text (String.fromInt index) ]
                , td [ style "width" "40%" ] [ text a.text ]
                , td [ style "width" "25%" ] []
                , td [ style "width" "20%" ] []
                , td [ style "width" "10%" ]
                    [ i
                        [ class "fas fa-arrow-up"
                        , onClick (PutUpEl element)
                        ]
                        []
                    , i
                        [ class "fas fa-arrow-down"
                        , onClick (PutDownEl element)
                        , style "margin-left" "1em"
                        , style "margin-right" "1em"
                        ]
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
                [ td [ style "width" "5%" ] [ text (String.fromInt index) ]
                , td [ style "width" "40%" ] [ text f.text ]
                , td [ style "width" "25%" ] [ text f.hint ]
                , td [ style "width" "20%" ] [ text f.typ ]
                , td [ style "width" "10%" ]
                    [ i
                        [ class "fas fa-arrow-up"
                        , onClick (PutUpEl element)
                        ]
                        []
                    , i
                        [ class "fas fa-arrow-down"
                        , onClick (PutDownEl element)
                        , style "margin-left" "1em"
                        , style "margin-right" "1em"
                        ]
                        []
                    , i
                        [ class "fas fa-cog"
                        , onClick (EditQuestion element)
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


{-| Zeigt die Tabelle mit den Antworten der "Inputfrage" (newElement) an.
-}
answersTable : Questionnaire -> List (Html Msg)
answersTable questionnaire =
    case questionnaire.newElement of
        Question record ->
            List.append [ tableHead_answers ] (List.indexedMap getAnswerTable (QElement.getAntworten questionnaire.newElement))

        Note record ->
            []


{-| Der Tabellenkopf der Tabelle von Antworten.
-}
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


{-| Darstellung einer Frage in einer Tabelle.
-}
getAnswerTable : Int -> Answer -> Html Msg
getAnswerTable index answer =
    tr [ id (String.fromInt index) ]
        [ td [] [ text (String.fromInt index) ]
        , td [] [ text answer.text ]
        , td [] [ text answer.typ ]
        , td []
            [ i
                [ class "fas fa-arrow-up"
                , onClick (PutUpAns answer)
                ]
                []
            , i
                [ class "fas fa-arrow-down"
                , onClick (PutDownAns answer)
                , style "margin-left" "1em"
                , style "margin-right" "1em"
                ]
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


{-| Tabelle von Bedingungen der "Input-Frage" (newElement).
-}
conditionsTable : Questionnaire -> List (Html Msg)
conditionsTable questionnaire =
    case questionnaire.newElement of
        Question record ->
            List.append [ tableHead_conditions ] (List.indexedMap getConditionTable questionnaire.conditions)

        Note record ->
            []


{-| Tabellenkopf der Tabelle für Bedingungen.
-}
tableHead_conditions : Html Msg
tableHead_conditions =
    tr []
        [ th []
            [ text "Von"
            ]
        , th []
            [ text "Zu"
            ]
        , th []
            [ text "Aktion"
            ]
        ]


{-| Tabellendarstellung einer Condition.
-}
getConditionTable : Int -> Condition -> Html Msg
getConditionTable index condition =
    tr [ id (String.fromInt index) ]
        [ td [] [ text (String.fromInt index) ]
        , td [] []
        , td []
            [ i
                [ class "fas fa-trash-alt"
                ]
                []
            ]
        ]


{-| Ausgabe, ob die Eingaben gültig sind.
-}
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


{-| TODO: KOMMENTAR RICHTIG SO? WIESO NICHT MIT viewValidation LÖSEN?
Ausgabe, ob die Eingabefrage gültig ist.
-}
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


{-| Eingabeoberfläche, wie viele Antworten für uni-/bipolare Fragen erstellt werden sollen.
-}
showInputBipolarUnipolar : Questionnaire -> Html Msg
showInputBipolarUnipolar questionnaire =
    case questionnaire.newElement of
        Question record ->
            if record.typ == "Skaliert unipolar" then
                div []
                    [ text "Bitte Anzahl Antworten (insgesamt) eingeben"
                    , input
                        [ class "input is-medium"
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
                        [ class "input is-medium"
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


{-| Radiobutton.
-}
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
