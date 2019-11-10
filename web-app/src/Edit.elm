module Edit exposing (answersTable, getAnswerTable, getQuestionOptions, getQuestionTable, questionsTable, radio, showCreateQuestionOrNoteButtons, showEditQuestionnaire, showHeroQuestionnaireTitle, showInputBipolarUnipolar, showQuestionList, showTimes, tableHead_answers, tableHead_questions, viewEditTimeModal, viewNewAnswerModal, viewNewNoteModal, viewNewQuestionModal, viewQuestionValidation, viewTitleModal, viewValidation, viewViewingTimeModal, convMaybeDateTime)

{-| Enthält die View für das Bearbeiten von Fragebögen.


# Öffentliche Funktionen

@docs answersTable, getAnswerTable, getQuestionOptions, getQuestionTable, questionsTable, radio, showCreateQuestionOrNoteButtons, showEditQuestionnaire, showHeroQuestionnaireTitle, showInputBipolarUnipolar, showQuestionList, showTimes, tableHead_answers, tableHead_questions, viewEditTimeModal, viewNewAnswerModal, viewNewNoteModal, viewNewQuestionModal, viewQuestionValidation, viewTitleModal, viewValidation, viewViewingTimeModal

-}

import Answer exposing (Answer)
import Condition exposing (Condition)
import Html exposing (Html, a, br, button, div, footer, h1, header, i, input, label, li, option, p, section, select, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, id, maxlength, minlength, multiple, name, placeholder, selected, style, type_, value)
import Html.Events exposing (onClick, onInput)
import List exposing (member, map)
import Model exposing (ModalType(..), Model, Msg(..), ValidationResult(..))
import QElement exposing (Q_element(..), NoteRecord, QuestionRecord)
import Questionnaire exposing (Questionnaire)
import DateTimePicker exposing (..)
import DateTimePicker.Config exposing (..)
import Html.Styled
import Html.Styled.Attributes
import Time exposing (..)



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
                    [ div [style "margin-bottom" "280px"]
                        [ text "Von "
                        , Html.Styled.toUnstyled (DateTimePicker.dateTimePickerWithConfig
                            customConfigViewingTimeBegin
                            [ Html.Styled.Attributes.class "my-timepicker"
                            , Html.Styled.Attributes.placeholder "DD:MM:YYYY:HH:MM"
                            ]
                            model.viewingTimeBeginPickerState
                            model.viewingTimeBeginPickerValue)
                        , text " Bis "
                        , Html.Styled.toUnstyled (DateTimePicker.dateTimePickerWithConfig
                            customConfigViewingTimeEnd
                            [ Html.Styled.Attributes.class "my-timepicker"
                            , Html.Styled.Attributes.placeholder "DD:MM:YYYY:HH:MM"
                            ]
                            model.viewingTimeEndPickerState
                            model.viewingTimeEndPickerValue)
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

customConfigViewingTimeBegin =
    let
        default =
            defaultDateTimePickerConfig ChangeViewingTimeBeginPicker
    in
    { default
        | toInput = convDateTime
        , fromInput = convInput
    }

customConfigViewingTimeEnd =
    let
        default =
            defaultDateTimePickerConfig ChangeViewingTimeEndPicker
    in
    { default
        | toInput = convDateTime
        , fromInput = convInput
    }

convInput : String -> Maybe DateTime
convInput input =
    if input == ""
    then Nothing
    else Just (dateTime (toIntYear input) (toIntMonth2 input) (toIntDay input) (toIntHour input) (toIntMinute input))

toIntYear : String -> Int
toIntYear string = 
    case List.head (List.reverse (String.split "." string)) of
        Nothing -> 0
        Just val -> case String.toInt (String.slice 1 4 val) of
                        Nothing -> 0
                        Just value -> value

toIntMonth2 : String -> Month
toIntMonth2 string =
    case List.tail (String.split "." string) of
        Nothing -> Jan
        Just val ->   case List.head val of
                            Nothing -> Jan
                            Just value -> case value of
                                            "01" -> Jan
                                            "02" -> Feb
                                            "03" -> Mar
                                            "04" -> Apr
                                            "05" -> May
                                            "06" -> Jun
                                            "07" -> Jul
                                            "08" -> Aug
                                            "09" -> Sep
                                            "10" -> Oct
                                            "11" -> Nov
                                            "12" -> Dec
                                            _    -> Jan

toIntDay : String -> Int
toIntDay string =
    case List.head (String.split "." string) of
        Nothing -> 0
        Just val -> case String.toInt val of
                        Nothing -> 0
                        Just value -> value

toIntHour : String -> Int
toIntHour string =
    case List.head (List.reverse (String.split " " string)) of
        Nothing -> 0
        Just val -> case String.toInt (String.left 2 val) of
                        Nothing -> 0
                        Just value -> value

toIntMinute : String -> Int
toIntMinute string =
    case List.head (List.reverse (String.split " " string)) of
        Nothing -> 0
        Just val -> case String.toInt (String.right 2 val) of
                        Nothing -> 0
                        Just value -> value

convMaybeDateTime : Maybe DateTime -> String
convMaybeDateTime dateTime =
    case dateTime of
        Nothing -> ""
        Just val -> toDayString val.day ++ "." ++ toMonthString val.month ++ "." ++ toYearString val.year ++ " " ++ toTimeString val.hour ++ ":" ++  toTimeString val.minute

convDateTime : DateTime -> String
convDateTime dateTime =
    toDayString dateTime.day ++ "." ++ toMonthString dateTime.month ++ "." ++ toYearString dateTime.year ++ " " ++ toTimeString dateTime.hour ++ ":" ++  toTimeString dateTime.minute

toMonthString : Month -> String
toMonthString month =
    case month of
        Jan -> "01"
        Feb -> "02"
        Mar -> "03"
        Apr -> "04"
        May -> "05"
        Jun -> "06"
        Jul -> "07"
        Aug -> "08"
        Sep -> "09"
        Oct -> "10"
        Nov -> "11"
        Dec -> "12"

toDayString : Int -> String
toDayString day =
    if day < 10 then "0" ++ String.fromInt day
    else String.fromInt day

toYearString : Int -> String
toYearString year =
    if year < 10 then "200" ++ String.fromInt year
    else if year < 100 then "20" ++ String.fromInt year
    else "2" ++ String.fromInt year

toTimeString : Int -> String
toTimeString time =
    if time < 10 then "0" ++ String.fromInt time
    else String.fromInt time

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
                        [ table [ class "table is-striped", style "width" "100%" ] (answersTable model)
                        , br [] []
                        , button [ class "qnButton", style "margin-bottom" "10px", onClick (ViewOrClose AnswerModal) ] [ text "Neue Antwort" ]
                        , br [] []
                        , showInputBipolarUnipolar model
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
                        , br [] []
                        , text ("Typ: " ++ QElement.getQuestionTyp model.newElement)
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

{-| Zeigt eine Liste von Fragen an, die zur Bedingung als "Elternfrage" oder "Kindfrage" hinzugefügt werden können.
Siehe viewConditionModal
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
                        [ table [ class "table is-striped", style "width" "100%" ] (conditionsTable model)
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
                                (getQuestionOptions model.questionnaire.elements model.newCondition)
                            ]
                        , br [] []
                        , text " zu Frage: "
                        , br [] []
                        , div [ class "select" ]
                            [ select [ onInput ChangeInputChildId ]
                                (getQuestionOptions model.questionnaire.elements model.newCondition)
                            ]
                        , br [] []
                        , text "Bei Beantwortung der Antworten mit den IDs: "
                        , br [] []
                        , div [ class "select" ]
                            [ select [ onInput ChangeInputAnswerId ]
                                (getAnswerOptions model model.newCondition)
                            ]
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
answersTable : Model -> List (Html Msg)
answersTable model =
    case model.newElement of
        Question record ->
            List.append [ tableHead_answers ] (List.indexedMap getAnswerTable (QElement.getAntworten model.newElement))

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
conditionsTable : Model -> List (Html Msg)
conditionsTable model =
    case model.newElement of
        Question record ->
            List.append [ tableHead_conditions ] (List.indexedMap getConditionTable model.questionnaire.conditions)

        Note record ->
            []


{-| Tabellenkopf der Tabelle für Bedingungen.
-}
tableHead_conditions : Html Msg
tableHead_conditions =
    tr []
        [ th []
            [ text "ID"
            ]
        , th []
            [ text "Von"
            ]
        , th []
            [ text "Zu"
            ]
        , th []
            [ text "Mit der Antwort/en"
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
        , td [] [ text (String.fromInt condition.parent_id) ]
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
showInputBipolarUnipolar : Model -> Html Msg
showInputBipolarUnipolar model =
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

get : Int -> List a -> Maybe a
get nth list =
    list
        |> List.drop (nth - 1)
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
            }

getAnswersId : List Answer -> List Int
getAnswersId list = 
    map Answer.getAnswerId list

