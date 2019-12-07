module Edit exposing (answersTable, getAnswerTable, getQuestionOptions, getQuestionTable, questionsTable, radio, showCreateQuestionOrNoteButtons, showEditQuestionnaire, showHeroQuestionnaireTitle, showInputBipolarUnipolarTableSlider, showQuestionList, tableHead_answers, tableHead_questions, viewEditTimeModal, viewNewAnswerModal, viewNewNoteModal, viewNewQuestionModal, viewQuestionValidation, viewTitleModal, viewValidation, viewViewingTimeModal)

{-| Contains the view for editing questionnaires.


# Public functions

@docs answersTable, getAnswerTable, getQuestionOptions, getQuestionTable, questionsTable, radio, showCreateQuestionOrNoteButtons, showEditQuestionnaire, showHeroQuestionnaireTitle, showInputBipolarUnipolarTableSlider, showQuestionList, tableHead_answers, tableHead_questions, viewEditTimeModal, viewNewAnswerModal, viewNewNoteModal, viewNewQuestionModal, viewQuestionValidation, viewTitleModal, viewValidation, viewViewingTimeModal

-}

import Answer exposing (Answer)
import Condition exposing (Condition)
import Html exposing (Html, a, br, button, div, footer, h1, header, i, input, label, li, option, p, section, select, small, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, id, maxlength, minlength, multiple, name, placeholder, selected, style, type_, value)
import Html.Events exposing (onClick, onInput)
import List exposing (member, map)
import Model exposing (ModalType(..), Model, Msg(..), ValidationResult(..))
import QElement exposing (Q_element(..), NoteRecord, QuestionRecord)
import Questionnaire exposing (Questionnaire)
import Time exposing (..)



{-| Displays the interface or view for editing questionnaires.
-}
showEditQuestionnaire : Model -> Html Msg
showEditQuestionnaire model =
    div []
        [ showHeroQuestionnaireTitle model.questionnaire
        , showQuestionList model.questionnaire
        , showCreateQuestionOrNoteButtons model.questionnaire
        , viewTitleModal model
        , viewEditTimeModal model
        , viewViewingTimeModal model
        , viewNewNoteModal model
        , viewNewQuestionModal model
        , viewNewAnswerModal model
        , viewNewConditionModalOverview model
        , viewNewConditionModalCreate model
        ]


{-| Displays the title of the questionnaire in a hero (see Bulma.io).
-}
showHeroQuestionnaireTitle : Questionnaire -> Html Msg
showHeroQuestionnaireTitle questionnaire =
    section [ class "hero is-info" ]
        [ div [ class "hero-body" ]
            [ div [ class "container is-fluid" ]
                [ h1 [ id "page-title", class "title" ]
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


{-| Displays a table with the questions and annotations from the questionnaire.
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


{-| Displays the buttons for creating new items (questions, annotations) for the questionnaire.
-}
showCreateQuestionOrNoteButtons : Questionnaire -> Html Msg
showCreateQuestionOrNoteButtons questionnaire =
    div [ class "container is-fluid divButtons" ]
        [ button
            [ class "qnButton"
            , style "margin-right" "10px"
            , onClick (ViewOrClose QuestionModal) ]
            [ text "Neue Frage" ]
        , button
            [ class "qnButton"
            , style "margin-right" "10px"
            , onClick (ViewOrClose NewNoteModal) ]
            [ text "Neue Anmerkung" ]
        , button
            [ class "qnButton"
            , style "margin-right" "10px"
            , onClick (ViewOrClose ConditionModalOverview) ]
            [ text "Bedingungen" ]
        , button
            [ class "qnButton"
            , onClick DownloadQuestionnaire ]
            [ text "Download" ]
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
                    [ div [style "margin-bottom" "280px"]
                        [ text "Von "
                        , text " Bis "
                        , br [style "margin-bottom" "20px"] []
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
                , section [ class "modal-card-body"]
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

{-| Displays the modal for editing the questionnaire title.
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
                        [ text "Titel: "
                        , input
                            [ class "input is-medium"
                            , type_ "text"
                            , style "width" "180px"
                            , style "margin-left" "32px"
                            , style "margin-right" "10px"
                            , value model.inputTitle
                            , onInput ChangeInputQuestionnaireTitle
                            ]
                            []
                        , br [] []
                        , text "Priorität: "
                        , input 
                            [ class "input is-medium"
                            , type_ "text"
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , style "margin-right" "10px"
                            , value ( String.fromInt model.inputPriority ) 
                            , onInput ChangeInputPriority
                            ]
                            []
                        , small [] [ text "(0 ist die höchste Priorität)" ]
                        ]
                    ]
                , footer [ class "modal-card-foot mediumlightblue" ]
                    [ button
                        [ class "qnButton"
                        , onClick SetQuestionnaireTitlePriority
                        ]
                        [ text "Übernehmen" ]
                    ]
                ]
            ]

    else
        div [] []


{-| Displays the modal for creating an annotation.
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
                            , value (QElement.getElementText model.newElement)
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


{-| Displays the modal for creating a new question.
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
                        [ showAnswerTable model
                        , br [] []
                        , showNewAnswerButton model
                        , br [] []
                        , showInputBipolarUnipolarTableSlider model
                        , br [ style "margin-top" "20px" ] []
                        , text "Fragetext: "
                        , input
                            [ class "input is-medium"
                            , type_ "text"
                            , style "width" "100%"
                            , value (QElement.getElementText model.newElement)
                            , onInput ChangeQuestionOrNoteText
                            ]
                            []
                        , br [ style "margin-top" "20px" ] []
                        , text "Hinweis: "
                        , input
                            [ class "input is-medium"
                            , type_ "text"
                            , style "width" "100%"
                            , value (QElement.getQuestionHinweis model.newElement)
                            , onInput ChangeQuestionNote
                            ]
                            []
                        , br [style "margin-top" "20px"] []
                        , text ("Typ: " ++ QElement.getQuestionTyp model.newElement)
                        , br [] []
                        , selectedRadio "Single Choice" (ChangeQuestionType "Single Choice")
                        , radio "Multiple Choice" (ChangeQuestionType "Multiple Choice")
                        , radio "Ja/Nein Frage" (ChangeQuestionType "Ja/Nein Frage")
                        , radio "Skaliert unipolar" (ChangeQuestionType "Skaliert unipolar")
                        , radio "Skaliert bipolar" (ChangeQuestionType "Skaliert bipolar")
                        , radio "Raster-Auswahl" (ChangeQuestionType "Raster-Auswahl")
                        , radio "Prozentslider" (ChangeQuestionType "Prozentslider")
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

{-| Displays a list of questions that can be added to the condition as "parent question" or "child question".
See viewConditionModal
-}
getQuestionOptions : List Q_element -> Condition -> List (Html Msg)
getQuestionOptions list newCondition =
    [ option [] [ text "Keine" ] ]
        ++ List.map (\e -> option [ selected (QElement.getElementId e == newCondition.parent_id) ]
            [ text (String.fromInt (QElement.getElementId e) ++ "." ++ " " ++ QElement.getElementText e) ]) list

getAnswerOptions : Model -> Condition -> List (Html Msg)
getAnswerOptions model newCondition =
    let
        parent_frage = checkFrage (get model.newCondition.parent_id model.questionnaire.elements)
        parent_antworten = (parent_frage.answers)
        list = parent_antworten
    in
        [ option [] [ text "Keine" ] ]
            ++ List.map (\e -> option [ selected (Answer.getAnswerId e == newCondition.answer_id) ]
                [ text (String.fromInt(Answer.getAnswerId e) ++ "." ++ " " ++ Answer.getAnswerText e) ]) list


{-| Displays a modal for creating new answers.
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
                        [ text ("Typ: " ++ model.newAnswer.typ)
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


{-| Displays a modal with a table of existing conditions.
-}
viewNewConditionModalOverview : Model -> Html Msg
viewNewConditionModalOverview model =
    if model.showNewConditionModalOverview then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head mediumlightblue" ]
                    [ p [ class "modal-card-title is-size-3 has-text-centered is-italic" ] [ text "Bedingungen" ]
                    , button [ class "is-large delete", onClick (ViewOrClose ConditionModalOverview) ] []
                    ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ table [ class "table is-striped", style "width" "100%" ] (conditionsTable model)
                        ]
                    ]
                , footer [ class "modal-card-foot mediumlightblue" ]
                    [ button
                        [ class "qnButton"
                        , onClick (ViewOrClose ConditionModalCreate)
                        ]
                        [ text "Neu" ]
                    ]
                ]
            ]

    else
        div [] []


{-| Displays a modal for creating conditions.
-}
viewNewConditionModalCreate : Model -> Html Msg
viewNewConditionModalCreate model =
    if model.showNewConditionModalCreate then
        div [ class "modal is-active" ]
            [ div [ class "modal-background" ] []
            , div [ class "modal-card" ]
                [ header [ class "modal-card-head mediumlightblue" ]
                    [ p [ class "modal-card-title is-size-3 has-text-centered is-italic" ] [ text "Bedingungen" ]
                    , button [ class "is-large delete", onClick (ViewOrClose ConditionModalCreate) ] []
                    ]
                , section [ class "modal-card-body" ]
                    [ div []
                        [ text "von Frage: "
                        , br [] []
                        , div [ class "select" ]
                            [ select [ onInput ChangeInputParentId ]
                                (getQuestionOptions model.questionnaire.elements model.newCondition)
                            ]
                        , br [style "margin-top" "20px"] []
                        , text " zu Frage: "
                        , br [] []
                        , div [ class "select" ]
                            [ select [ onInput ChangeInputChildId ]
                                (getQuestionOptions model.questionnaire.elements model.newCondition)
                            ]
                        , br [style "margin-top" "20px"] []
                        , text "Bei Beantwortung der Antworten mit den IDs: "
                        , br [] []
                        , div [ class "select" ]
                            [ select [ onInput ChangeInputAnswerId ]
                                (getAnswerOptions model model.newCondition)
                            ]
                        ]
                    ]
                , footer [ class "modal-card-foot mediumlightblue" ]
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


{-| Displays a table of existing questions.
-}
questionsTable : Questionnaire -> List (Html Msg)
questionsTable questionnaire =
    List.indexedMap getQuestionTable questionnaire.elements


{-| The table header of the table with the available questions.
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


{-| The depiction of an element of the questionnaire in the table.
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


{-| Displays the table with the answers of the "input question" (newElement).
-}
answersTable : Model -> List (Html Msg)
answersTable model =
    case model.newElement of
        Question record ->
            List.append [ tableHead_answers ] (Debug.log "test" (List.indexedMap getAnswerTable (QElement.getAntworten model.newElement)))

        Note record ->
            []


{-| The table header of the table of answers.
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


{-| Depiction of a question in a table.
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


{-| Table of conditions of the "input question" (newElement).
-}
conditionsTable : Model -> List (Html Msg)
conditionsTable model =
    List.append [ tableHead_conditions ] (List.indexedMap getConditionTable model.questionnaire.conditions)
            


{-| Table header of the table for conditions.
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
            [ text "Mit der Antwort"
            ]
        , th []
            [ text "Aktion"
            ]
        ]


{-| Table representation of a condition.
-}
getConditionTable : Int -> Condition -> Html Msg
getConditionTable index condition =
    tr [ id (String.fromInt index) ]
        [ td [] [ text (String.fromInt condition.parent_id) ]
        , td [] [ text (String.fromInt condition.child_id) ]
        , td [] [ text (String.fromInt condition.answer_id) ]
        , td []
            [ i
                [ class "fas fa-cog"
                , style "margin-right" "1em"
                , onClick (EditCondition condition)
                ]
                []
            , i
                [ class "fas fa-trash-alt"
                , onClick (DeleteCondition condition)
                ]
                []
            ]
        ]


{-| Output whether the inputs are valid.
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


{-| Output whether the input question is valid.
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

{- entfernt die Antworten-Tabelle wenn Raster-Auswahl oder Prozentslider Fragetyp gewählt wurde
-}
showAnswerTable : Model -> Html Msg
showAnswerTable model =
    case model.newElement of
        Question record ->
            if record.typ == "Raster-Auswahl" || record.typ == "Prozentslider" then
                div [] []
            else
                table [ class "table is-striped", style "width" "100%" ] (answersTable model)

        Note record ->
            div [] []

{- entfernt die "Neue Antwort"-Button wenn Raster-Auswahl oder Prozentslider Fragetyp gewählt wurde
-}
showNewAnswerButton : Model -> Html Msg
showNewAnswerButton model =
    case model.newElement of
        Question record ->
            if record.typ == "Raster-Auswahl" || record.typ == "Prozentslider" then
                div [] []
            else
                button [ class "qnButton", style "margin-bottom" "10px", onClick (ViewOrClose AnswerModal) ] [ text "Neue Antwort" ]

        Note record ->
            div [] []

{-| Eingabeoberfläche, wie viele Antworten/Eingabefelder für uni-/bipolare, Raster-Auswahl und Prozentslider Fragen erstellt werden sollen.
-}
showInputBipolarUnipolarTableSlider : Model -> Html Msg
showInputBipolarUnipolarTableSlider model =
    case model.newElement of
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
                    ,br [] []
                    ,text "Beschriftung links:"
                    , input
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "20px"
                        , style "margin-top" "2px"
                        , value ( QElement.getLeftText model.newElement )
                        , onInput SetLeftText
                        ]
                        []
                    , br [] []
                    , text "Beschriftung rechts:"
                    , input
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "10px"
                        , style "margin-top" "2px"
                        , value ( QElement.getRightText model.newElement )
                        , onInput SetRightText
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
                    ,br [] []
                    ,text "Beschriftung links:"
                    , input
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "20px"
                        , style "margin-top" "2px"
                        , value ( QElement.getLeftText model.newElement )
                        , onInput SetLeftText
                        ]
                        []
                    , br [] []
                    , text "Beschriftung rechts:"
                    , input
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "10px"
                        , style "margin-top" "2px"
                        , value ( QElement.getRightText model.newElement )
                        , onInput SetRightText
                        ]
                        []
                    ]

            else if record.typ == "Raster-Auswahl" then
                div []
                    [ text "Raster-Größe: "
                    , div
                        [class "select"]
                        [ select
                            [ onInput SetTableSize ]
                            [ option [ value "3", selected ((QElement.getTableSize model.newElement) == 3) ] [ text "3x3" ]
                            , option [ value "5", selected ((QElement.getTableSize model.newElement) == 5) ] [ text "5x5" ]
                            , option [ value "7", selected ((QElement.getTableSize model.newElement) == 7)] [ text "7x7" ]
                            ]
                        ]
                    , br [] []
                    , text "Raster-Beschriftung oben:"
                    , input
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "17px"
                        , style "margin-top" "2px"
                        , value ( QElement.getTopText model.newElement )
                        , onInput SetTopText
                        ]
                        []
                    , br [] []
                    , text "Raster-Beschriftung rechts:"
                    , input
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "10px"
                        , style "margin-top" "2px"
                        , value ( QElement.getRightText model.newElement )
                        , onInput SetRightText
                        ]
                        []
                    , br [] []
                    , text "Raster-Beschriftung unten:"
                    , input
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "13px"
                        , style "margin-top" "2px"
                        , value ( QElement.getBottomText model.newElement )
                        , onInput SetBottomText
                        ]
                        []
                    , br [] []
                    , text "Raster-Beschriftung links:"
                    , input
                        [ class "input"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "20px"
                        , style "margin-top" "2px"
                        , value ( QElement.getLeftText model.newElement )
                        , onInput SetLeftText
                        ]
                        []
                    ]

            else if record.typ == "Prozentslider" then
                div []
                    [ text "Bitte linken Grenzwert eingeben:   "
                    , input
                        [ class "input is-medium"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "16px"
                        , style "margin-top" "2px"
                        , value ( QElement.getLeftText model.newElement )
                        , onInput SetLeftText
                        ]
                        []
                    , br [] []
                    , text "Bitte rechten Grenzwert eingeben:"
                    , input
                        [ class "input is-medium"
                        , type_ "text"
                        , style "width" "100px"
                        , style "margin-left" "10px"
                        , style "margin-top" "2px"
                        , value ( QElement.getRightText model.newElement )
                        , onInput SetRightText
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

selectedRadio : String -> msg -> Html msg
selectedRadio value msg =
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
        
get : Int -> List a -> Maybe a
get nth list =
    list
        |> List.drop (nth)
        |> List.head

checkFrage : Maybe Q_element -> QuestionRecord
checkFrage frage =

     case frage of
        Just (Question f) ->
            f

        _ ->
            { id = 0
            , text = "Beispielfrage"
            , answers = []
            , hint = ""
            , typ = ""
            , questionTime = ""
            , tableSize = 0
            , topText = ""
            , rightText = ""
            , bottomText = ""
            , leftText = ""
            }

getAnswersId : List Answer -> List Int
getAnswersId list =
    map Answer.getAnswerId list
