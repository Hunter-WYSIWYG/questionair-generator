module Main exposing (subscriptions, main, update, view)

{-| Main enthält die Hauptfunktionen der WebApp.


# Funktionen

@docs subscriptions, main, update, view

-}

import Answer exposing (Answer)
import Browser
import Condition
import Decoder
import Edit
import Encoder
import File exposing (File)
import File.Select as Select
import Html exposing (Html, a, br, div, nav, p, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import List
import Model exposing (ModalType(..), Model, Msg(..), ValidationResult(..))
import QElement exposing (Q_element(..))
import Questionnaire
import Task
import Upload


{-| Main-Funktion.
-}
main : Program () Model Msg
main =
    Browser.element
        { init = Model.initModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


{-| Subscriptions-Funktion
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


{-| Update-Funktion mit Logik der WebApp.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        --changing properties of notes or questions or answers
        ChangeInputQuestionnaireTitle newTitle ->
            ( { model | inputTitle = newTitle }, Cmd.none )

        ChangeEditTime newTime ->
            let
                changedModel =
                    { model | inputEditTime = newTime }
            in
            ( { model | inputEditTime = newTime, validationResult = Model.validate changedModel }, Cmd.none )

        ChangeViewingTimeBegin newTime ->
            let
                changedModel =
                    { model | inputViewingTimeBegin = newTime }
            in
            ( { model | inputViewingTimeBegin = newTime, validationResult = Model.validate changedModel }, Cmd.none )

        ChangeViewingTimeEnd newTime ->
            let
                changedModel =
                    { model | inputViewingTimeEnd = newTime }
            in
            ( { model | inputViewingTimeEnd = newTime, validationResult = Model.validate changedModel }, Cmd.none )

        ChangeQuestionOrNoteText string ->
            let
                changedRecord rec =
                    { rec | text = string }

                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    case oldQuestionnaire.newElement of
                        Question record ->
                            { oldQuestionnaire | newElement = Question (changedRecord record) }

                        Note record ->
                            { oldQuestionnaire | newElement = Note (changedRecord record) }
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        ChangeQuestionNewAnswer newAnswer ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    case oldQuestionnaire.newElement of
                        Question record ->
                            { oldQuestionnaire
                                | newElement =
                                    Question
                                        { record | answers = record.answers ++ [ newAnswer ] }
                            }

                        Note record ->
                            oldQuestionnaire
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        ChangeQuestionNote string ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    case oldQuestionnaire.newElement of
                        Question record ->
                            { oldQuestionnaire
                                | newElement =
                                    Question
                                        { record | hint = string }
                            }

                        Note record ->
                            oldQuestionnaire
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        ChangeQuestionType string ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    case oldQuestionnaire.newElement of
                        Question record ->
                            { oldQuestionnaire
                                | newElement =
                                    if string == "Single Choice" || string == "Multiple Choice" then
                                        Question { record | typ = string }

                                    else
                                        Question { record | typ = string, answers = Answer.getYesNoAnswers string }
                            }

                        Note record ->
                            oldQuestionnaire
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        ChangeQuestionTime newTime ->
            ( { model | inputQuestionTime = newTime, questionValidationResult = Model.validateQuestion newTime }, Cmd.none )

        ChangeAnswerText string ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire | newAnswer = Answer oldQuestionnaire.newAnswer.id string oldQuestionnaire.newAnswer.typ }
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        ChangeAnswerType string ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire
                        | newAnswer =
                            Answer oldQuestionnaire.newAnswer.id oldQuestionnaire.newAnswer.text string
                    }
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        --open or close modals
        ViewOrClose modalType ->
            case modalType of
                TitleModal ->
                    ( { model | showTitleModal = not model.showTitleModal }, Cmd.none )

                ViewingTimeModal ->
                    ( { model | showViewingTimeModal = not model.showViewingTimeModal }, Cmd.none )

                EditTimeModal ->
                    ( { model | showEditTimeModal = not model.showEditTimeModal }, Cmd.none )

                NewNoteModal ->
                    let
                        oldQuestionnaire =
                            model.questionnaire

                        changedQuestionnaire =
                            if not model.showNewNoteModal == True then
                                { oldQuestionnaire
                                    | newElement =
                                        Note
                                            { id = List.length oldQuestionnaire.elements
                                            , text = ""
                                            }
                                }

                            else
                                oldQuestionnaire
                    in
                    ( { model | questionnaire = changedQuestionnaire, showNewNoteModal = not model.showNewNoteModal }, Cmd.none )

                QuestionModal ->
                    let
                        oldQuestionnaire =
                            model.questionnaire

                        changedQuestionnaire =
                            if not model.showNewQuestionModal == True then
                                { oldQuestionnaire
                                    | newElement =
                                        Question
                                            { id = List.length oldQuestionnaire.elements
                                            , text = ""
                                            , answers = []
                                            , hint = ""
                                            , typ = ""
                                            , questionTime = ""
                                            }
                                }

                            else
                                oldQuestionnaire
                    in
                    ( { model
                        | questionnaire = changedQuestionnaire
                        , showNewQuestionModal = not model.showNewQuestionModal
                        , questionValidationResult = NotDone
                        , inputQuestionTime = ""
                      }
                    , Cmd.none
                    )

                AnswerModal ->
                    let
                        oldQuestionnaire =
                            model.questionnaire

                        changedQuestionnaire =
                            if not model.showNewAnswerModal == True then
                                { oldQuestionnaire
                                    | newAnswer =
                                        { id = List.length (QElement.getAntworten oldQuestionnaire.newElement)
                                        , text = ""

                                        --type can be "free" or "regular"
                                        , typ = ""
                                        }
                                }

                            else
                                oldQuestionnaire
                    in
                    ( { model | questionnaire = changedQuestionnaire, showNewAnswerModal = not model.showNewAnswerModal }, Cmd.none )

                ConditionModal1 ->
                    let
                        oldQuestionnaire =
                            model.questionnaire

                        changedQuestionnaire =
                            oldQuestionnaire
                    in
                    ( { model | questionnaire = changedQuestionnaire, showNewConditionModal1 = not model.showNewConditionModal1 }, Cmd.none )

                ConditionModal2 ->
                    let
                        oldQuestionnaire =
                            model.questionnaire

                        changedQuestionnaire =
                            oldQuestionnaire
                    in
                    ( { model | questionnaire = changedQuestionnaire, showNewConditionModal2 = not model.showNewConditionModal2 }, Cmd.none )

        --Add Condition
        ChangeInputParentId parent_id ->
            ( { model
                | inputParentId =
                    case String.toInt parent_id of
                        Just a ->
                            a

                        Nothing ->
                            -1
              }
            , Cmd.none
            )

        ChangeInputChildId child_id ->
            ( { model
                | inputChildId =
                    case String.toInt child_id of
                        Just a ->
                            a

                        Nothing ->
                            -1
              }
            , Cmd.none
            )

        AddCondition ->
            let
                parent =
                    model.inputParentId

                child =
                    model.inputChildId
            in
            if parent /= -1 && child /= -1 then
                ( { model
                    | newCondition = Condition.setParentChildInCondition parent child model.newCondition
                  }
                , Cmd.none
                )

            else
                Debug.log "Keine ausgewählt"
                    ( { model
                        | newCondition = Condition.setValid model.newCondition False
                      }
                    , Cmd.none
                    )

        AddConditionAnswer ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    case String.toInt oldQuestionnaire.newAnswerID_Condition of
                        Nothing ->
                            oldQuestionnaire

                        Just id ->
                            { oldQuestionnaire
                                | newCondition = Condition.addAnswerOfQuestionToCondition id oldQuestionnaire.newElement oldQuestionnaire.newCondition
                            }
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        AddAnswerToNewCondition string ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire | newAnswerID_Condition = string }
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        --Save input to questionnaire
        SetQuestionnaireTitle ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire | title = model.inputTitle }
            in
            ( { model | questionnaire = changedQuestionnaire, showTitleModal = not model.showTitleModal, inputTitle = "" }, Cmd.none )

        SetPolarAnswers string ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    case oldQuestionnaire.newElement of
                        Question record ->
                            if record.typ == "Skaliert unipolar" then
                                { oldQuestionnaire | newElement = Question { record | answers = Answer.getUnipolarAnswers string } }

                            else
                                { oldQuestionnaire | newElement = Question { record | answers = Answer.getBipolarAnswers string } }

                        Note record ->
                            oldQuestionnaire
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        SetNote ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    if model.editQElement == False then
                        { oldQuestionnaire
                            | elements = List.append oldQuestionnaire.elements [ oldQuestionnaire.newElement ]
                        }

                    else
                        { oldQuestionnaire
                            | elements = List.map (\e -> QElement.updateElement oldQuestionnaire.newElement e) oldQuestionnaire.elements
                        }
            in
            if model.editQElement == False then
                ( { model | questionnaire = changedQuestionnaire, showNewNoteModal = False }, Cmd.none )

            else
                ( { model | questionnaire = changedQuestionnaire, showNewNoteModal = False, editQElement = False }, Cmd.none )

        SetQuestion ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    if model.editQElement == False then
                        { oldQuestionnaire
                            | elements = List.append oldQuestionnaire.elements [ oldQuestionnaire.newElement ]
                            , conditions =
                                if oldQuestionnaire.newCondition.isValid then
                                    Debug.log "true" (List.append oldQuestionnaire.conditions [ oldQuestionnaire.newCondition ])

                                else
                                    Debug.log "false" Condition.removeConditionFromCondList oldQuestionnaire.newCondition oldQuestionnaire.conditions
                            , newCondition = Condition.initCondition
                        }

                    else
                        { oldQuestionnaire
                            | elements = List.map (\e -> QElement.updateElement oldQuestionnaire.newElement e) oldQuestionnaire.elements
                            , conditions =
                                if oldQuestionnaire.newCondition.isValid then
                                    Debug.log "true" List.map (\e -> Condition.updateCondition oldQuestionnaire.newCondition e) oldQuestionnaire.conditions

                                else
                                    Debug.log "false" Condition.removeConditionFromCondList oldQuestionnaire.newCondition oldQuestionnaire.conditions
                        }
            in
            if model.editQElement == False then
                ( { model | questionnaire = changedQuestionnaire, showNewQuestionModal = False }, Cmd.none )

            else
                ( { model | questionnaire = changedQuestionnaire, showNewQuestionModal = False, editQElement = False }, Cmd.none )

        SetConditions ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire | conditions = List.append oldQuestionnaire.conditions [ oldQuestionnaire.newCondition ] }
            in
            ( { model | questionnaire = changedQuestionnaire, showNewConditionModal2 = False }, Cmd.none )

        SetAnswer ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    case oldQuestionnaire.newElement of
                        Question record ->
                            if model.editAnswer == False && oldQuestionnaire.newAnswer.typ /= "" then
                                { oldQuestionnaire
                                    | newElement =
                                        Question { record | answers = record.answers ++ [ oldQuestionnaire.newAnswer ] }
                                }

                            else if oldQuestionnaire.newAnswer.typ == "" then
                                oldQuestionnaire

                            else
                                { oldQuestionnaire
                                    | newElement =
                                        Question { record | answers = List.map (\e -> Answer.update oldQuestionnaire.newAnswer e) record.answers }
                                }

                        Note record ->
                            oldQuestionnaire
            in
            if model.editAnswer == False && oldQuestionnaire.newAnswer.typ /= "" then
                ( { model | questionnaire = changedQuestionnaire, showNewAnswerModal = False }, Cmd.none )

            else if oldQuestionnaire.newAnswer.typ == "" then
                ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

            else
                ( { model | questionnaire = changedQuestionnaire, showNewAnswerModal = False, editAnswer = False }, Cmd.none )

        --Edits already existing elements
        EditAnswer element ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire
                        | newAnswer = element
                    }
            in
            ( { model | questionnaire = changedQuestionnaire, showNewAnswerModal = True, editAnswer = True }, Cmd.none )

        EditQuestion element ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire
                        | newElement = element
                        , newCondition = Condition.getConditionWithParentID oldQuestionnaire.conditions (QElement.getID element)
                    }
            in
            ( { model | questionnaire = changedQuestionnaire, showNewQuestionModal = True, editQElement = True }, Cmd.none )

        EditNote element ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire
                        | newElement = element
                    }
            in
            ( { model | questionnaire = changedQuestionnaire, showNewNoteModal = True, editQElement = True }, Cmd.none )

        EditQuestionnaire ->
            ( { model | upload = False, editQuestionnaire = True }, Cmd.none )

        --Change order of elements
        PutDownEl element ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    if QElement.getID element /= (List.length oldQuestionnaire.elements - 1) then
                        { oldQuestionnaire
                            | elements = QElement.putElementDown oldQuestionnaire.elements element
                            , conditions = Condition.updateIDsInCondition oldQuestionnaire.conditions (QElement.getID element) (QElement.getID element + 1)
                        }

                    else
                        oldQuestionnaire
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        PutUpEl element ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    if QElement.getID element /= 0 then
                        { oldQuestionnaire
                            | elements = QElement.putElementUp oldQuestionnaire.elements element
                            , conditions = Condition.updateIDsInCondition oldQuestionnaire.conditions (QElement.getID element) (QElement.getID element - 1)
                        }

                    else
                        oldQuestionnaire
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        PutUpAns answer ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    if answer.id /= 0 then
                        { oldQuestionnaire
                            | newElement = QElement.putAnswerUp oldQuestionnaire.newElement answer
                            , conditions = Condition.updateConditionAnswers oldQuestionnaire.conditions answer.id (answer.id - 1)
                        }

                    else
                        oldQuestionnaire
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        PutDownAns answer ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    if answer.id /= (List.length (QElement.getAntworten oldQuestionnaire.newElement) - 1) then
                        { oldQuestionnaire | newElement = QElement.putAnswerDown oldQuestionnaire.newElement answer }

                    else
                        oldQuestionnaire
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        --Delete existing elements or answers
        DeleteItem element ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire
                        | elements = QElement.deleteItemFrom element oldQuestionnaire.elements
                        , conditions = Condition.deleteConditionWithElement oldQuestionnaire.conditions (QElement.getID element)
                    }
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        DeleteAnswer answer ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire
                        | newElement = QElement.deleteAnswerFromItem answer oldQuestionnaire.newElement
                        , conditions = List.map (Condition.deleteAnswerInCondition answer.id) oldQuestionnaire.conditions
                    }
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        -- validate inputs on submit and then save changes
        Submit ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire
                        | editTime = model.inputEditTime
                        , viewingTimeBegin = model.inputViewingTimeBegin
                        , viewingTimeEnd = model.inputViewingTimeEnd
                    }
            in
            if Model.validate model == ValidationOK then
                ( { model
                    | questionnaire = changedQuestionnaire
                    , showViewingTimeModal = False
                    , showEditTimeModal = False
                    , validationResult = ValidationOK
                  }
                , Cmd.none
                )

            else
                ( { model
                    | validationResult = Model.validate model
                    , inputViewingTimeBegin = ""
                    , inputViewingTimeEnd = ""
                    , inputEditTime = ""
                  }
                , Cmd.none
                )

        --Everything releated to upload
        EnterUpload ->
            ( { model | upload = True }, Cmd.none )

        LeaveOrEnterUpload ->
            ( { model | upload = not model.upload }, Cmd.none )

        JsonRequested ->
            ( model
            , Select.file [ "text/json" ] JsonSelected
            )

        JsonSelected file ->
            ( model
            , Task.perform JsonLoaded (File.toString file)
            )

        JsonLoaded content ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire
                        | title = Decoder.decodeTitle content
                        , elements = Decoder.decodeElements content
                    }
            in
            ( { model | questionnaire = changedQuestionnaire, upload = False, editQuestionnaire = True }, Cmd.none )

        --Everything releated to download
        DownloadQuestionnaire ->
            ( model, Encoder.save model.questionnaire (Encoder.encodeQuestionnaire model.questionnaire) )


{-| Anzeige der Views für das Editieren und Uploaden von Fragebögen.
-}
view : Model -> Html Msg
view model =
    div [ class "lightblue" ]
        [ showNavbar
        , if model.upload then
            Upload.showUpload model

          else
            Edit.showEditQuestionnaire model
        ]


{-| Anzeige einer Navbar mit Optionen, um zischen den Views für das Bearbeiten und Uploaden von Fragebögen zu wechseln.
-}
showNavbar : Html Msg
showNavbar =
    nav [ class "navbar is-fixed-top is-link" ]
        [ div [ class "navbar-brand" ]
            [ p [ class "navbar-item", style "padding-top" "0.5em" ] [ text "Fragebogengenerator" ] ]
        , div [ class "navbar-menu" ]
            [ div [ class "navbar-start" ]
                [ a [ class "navbar-item", onClick EditQuestionnaire ] [ text "Fragebogen Erstellen" ]
                , a [ class "navbar-item", onClick EnterUpload ] [ text "Fragebogen Hochladen" ]
                ]
            ]
        ]
