module Main exposing (..)

import Browser
import Edit exposing (..)
import File exposing (File)
import File.Select as Select
import Html exposing (Html, div, br, section, h1, text, nav, p, a, button)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import List exposing (append)
import Model exposing (..)
import Msg exposing (..)
import Task
import Encoder exposing (..)
import Decoder exposing (..)
import Questionnaire exposing (..)
import QElement exposing (Q_element(..), getAntworten, getID, updateElement, deleteItemFrom, putElementDown, deleteAnswerFromItem, putElementUp, putAnswerDown, putAnswerUp)
import Answer exposing (Answer, setPredefinedAnswers, getUnipolarAnswers, getBipolarAnswers, updateAnswer)
import Condition exposing (setValid, updateConditionWithIdTo, updateConditionAnswers, deleteConditionWithElement, deleteAnswerInCondition, setParentChildInCondition, addAnswerOfQuestionToCondition, removeConditionFromCondList, initCondition, updateCondition, getConditionWithParentID)


main =
    Browser.element
        { init = initModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


--Init
initModel : () -> ( Model, Cmd Msg )
initModel _ = 
    ({ questionnaire = initQuestionnaire

    --modals
    , showTitleModal = False
    , showEditTimeModal = False
    , showViewingTimeModal = False
    , showNewNoteModal = False
    , showNewQuestionModal = False
    , showNewAnswerModal = False

    --editQElement for EditQuestion and EditNote
    , editQElement = False
    , editAnswer = False

    --new inputs
    , inputTitle = ""
    , validationResult = NotDone
    , inputEditTime = ""
    , inputViewingTimeBegin = ""
    , inputViewingTimeEnd = ""
    , inputQuestionTime = ""
    , questionValidationResult = NotDone


    --upload determines if the users wants to upload a questionnaire
    --if upload is false show UI to create new questionnaire
    , upload = False

    -- a page to edit Questionnaires
    , editQuestionnaire = True

    --Debug 
    , tmp = ""
    }, Cmd.none)


--Update logic


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        --changing properties of notes or questions or answers
        ChangeInputQuestionnaireTitle newTitle ->
            ( { model | inputTitle = newTitle }, Cmd.none )

        ChangeEditTime newTime ->
            let
                changedModel = { model | inputEditTime = newTime }
                --validatedModel = { changedModel | validationResult = validate changedModel }
            in
                ( { model | inputEditTime = newTime, validationResult = validate changedModel }, Cmd.none )

        ChangeViewingTimeBegin newTime ->
            let
                changedModel = { model | inputViewingTimeBegin = newTime}
                --validatedModel = { changedModel | validationResult = validate changedModel }
            in
                ( { model | inputViewingTimeBegin = newTime, validationResult = validate changedModel }, Cmd.none)

        ChangeViewingTimeEnd newTime ->
            let
                changedModel = { model | inputViewingTimeEnd = newTime }
                --validatedModel = { changedModel | validationResult = validate changedModel }
            in
                ( { model | inputViewingTimeEnd = newTime, validationResult = validate changedModel }, Cmd.none)

        ChangeQuestionOrNoteText string ->
            let
                changedRecord rec = { rec | text = string }
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire = 
                    case oldQuestionnaire.newElement of
                        Question record -> { oldQuestionnaire | newElement = Question (changedRecord record) }

                        Note record -> { oldQuestionnaire | newElement = Note (changedRecord record) }
            in
                ( { model | questionnaire = changedQuestionnaire}, Cmd.none )

        ChangeQuestionNewAnswer newAnswer ->
            let
                oldQuestionnaire = model.questionnaire
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
                oldQuestionnaire = model.questionnaire
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
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    case oldQuestionnaire.newElement of
                            Question record ->
                                { oldQuestionnaire
                                    | newElement =
                                        if string == "Single Choice" || string == "Multiple Choice" then
                                            Question { record | typ = string }
                                        else 
                                            Question { record | typ = string, answers = setPredefinedAnswers string }
                                }
                            Note record ->
                                oldQuestionnaire
            in
                ( { model | questionnaire = changedQuestionnaire }, Cmd.none )
            
        ChangeQuestionTime newTime ->
            ( { model | inputQuestionTime = newTime, questionValidationResult = validateQuestion newTime }, Cmd.none )
                
        ChangeAnswerText string ->
            let
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    { oldQuestionnaire | newAnswer = Answer oldQuestionnaire.newAnswer.id string oldQuestionnaire.newAnswer.typ }     
            in
                ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        ChangeAnswerType string ->
            let
                oldQuestionnaire = model.questionnaire
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
                        oldQuestionnaire = model.questionnaire
                        changedQuestionnaire =
                            if not model.showNewNoteModal == True then 
                                { oldQuestionnaire 
                                    |newElement = 
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
                        oldQuestionnaire = model.questionnaire
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
                            , inputQuestionTime = "" }
                        , Cmd.none 
                        )

                AnswerModal ->
                    let
                        oldQuestionnaire = model.questionnaire
                        changedQuestionnaire =
                            if not model.showNewAnswerModal == True then
                                { oldQuestionnaire
                                    | newAnswer =
                                        { id = (List.length (getAntworten oldQuestionnaire.newElement))
                                        , text = ""
                                        --type can be "free" or "regular"
                                        , typ = ""
                                        }
                                }
                            else 
                                oldQuestionnaire
                    in
                       ( { model | questionnaire = changedQuestionnaire, showNewAnswerModal = not model.showNewAnswerModal }, Cmd.none ) 

         --Add Condition
        AddCondition string ->
            let 
                oldQuestionnaire = model.questionnaire
                parent = getID oldQuestionnaire.newElement
                child = getID (getElementWithText string oldQuestionnaire)
                changedQuestionnaire =
                    if string == "Keine" then  
                        Debug.log "Keine ausgewählt" { oldQuestionnaire 
                            | newCondition = setValid oldQuestionnaire.newCondition False
                            --, conditions = removeConditionFromCondList questionnaire.newCondition questionnaire.conditions
                        }
                    else   
                        { oldQuestionnaire 
                                    | newCondition = setParentChildInCondition parent child oldQuestionnaire.newCondition
                        }
            in
                ( { model | questionnaire = changedQuestionnaire }, Cmd.none ) 

            
        AddConditionAnswer ->
            let
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire = 
                    case String.toInt (oldQuestionnaire.newAnswerID_Condition) of
                        Nothing ->
                            oldQuestionnaire
                        Just id ->
                            { oldQuestionnaire 
                                | newCondition = addAnswerOfQuestionToCondition id oldQuestionnaire.newElement oldQuestionnaire.newCondition }
            in
              ( { model | questionnaire = changedQuestionnaire }, Cmd.none )   
                            

        AddAnswerToNewCondition string ->
            let
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire = { oldQuestionnaire | newAnswerID_Condition = string }
                    
            in
               ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        --Save input to questionnaire
        SetQuestionnaireTitle ->
            let
              oldQuestionnaire = model.questionnaire
              changedQuestionnaire = { oldQuestionnaire| title = model.inputTitle }  
            in
                ( { model | questionnaire = changedQuestionnaire, showTitleModal = not model.showTitleModal, inputTitle = "" }, Cmd.none )

        SetPolarAnswers string ->
            let 
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    case oldQuestionnaire.newElement of
                        Question record ->
                            if record.typ == "Skaliert unipolar" then
                                { oldQuestionnaire | newElement = Question { record | answers = getUnipolarAnswers string } }
                            else
                                { oldQuestionnaire | newElement = Question { record | answers = getBipolarAnswers string } }
                        Note record ->
                            oldQuestionnaire
            in
                ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        SetNote ->
            let 
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    if model.editQElement == False then
                        { oldQuestionnaire
                            | elements = append oldQuestionnaire.elements [ oldQuestionnaire.newElement ]
                        --, showNewNoteModal = False
                        }
                    else
                        { oldQuestionnaire
                            | elements = List.map (\e -> updateElement oldQuestionnaire.newElement e) oldQuestionnaire.elements
                            --, showNewNoteModal = False
                            --, editQElement = False
                  }
            in
                if model.editQElement == False then
                   ( { model | questionnaire = changedQuestionnaire, showNewNoteModal = False }, Cmd.none ) 
                else 
                    ( { model | questionnaire = changedQuestionnaire, showNewNoteModal = False, editQElement = False }, Cmd.none )

        SetQuestion ->
            let 
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    if model.editQElement == False then
                        { oldQuestionnaire
                            | elements = append oldQuestionnaire.elements [ oldQuestionnaire.newElement ]
                            , conditions =  if (oldQuestionnaire.newCondition.isValid) 
                                    then Debug.log "true" (append oldQuestionnaire.conditions [ oldQuestionnaire.newCondition ]) 
                                    else Debug.log "false" removeConditionFromCondList oldQuestionnaire.newCondition oldQuestionnaire.conditions
                            , newCondition = initCondition
                            --, showNewQuestionModal = False
                        }
                    else
                        { oldQuestionnaire
                            | elements = List.map (\e -> updateElement oldQuestionnaire.newElement e) oldQuestionnaire.elements
                            , conditions =  if (oldQuestionnaire.newCondition.isValid) 
                                    then Debug.log "true" List.map (\e -> updateCondition oldQuestionnaire.newCondition e) oldQuestionnaire.conditions 
                                    else Debug.log "false" removeConditionFromCondList oldQuestionnaire.newCondition oldQuestionnaire.conditions
                            --, showNewQuestionModal = False
                            --, editQElement = False
                        }
            in
               if model.editQElement == False then
                   ( { model | questionnaire = changedQuestionnaire, showNewQuestionModal = False }, Cmd.none ) 
                else 
                    ( { model | questionnaire = changedQuestionnaire, showNewQuestionModal = False, editQElement = False }, Cmd.none )
                  
        SetAnswer ->  
            let
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =                                                                   
                    case oldQuestionnaire.newElement of
                        Question record ->
                            if model.editAnswer == False && oldQuestionnaire.newAnswer.typ /= "" then
                                { oldQuestionnaire
                                    | newElement =
                                        Question { record | answers = record.answers ++ [ oldQuestionnaire.newAnswer ] }
                                    --, showNewAnswerModal = False
                                }
                            else if oldQuestionnaire.newAnswer.typ == "" then
                                oldQuestionnaire
                            else
                                { oldQuestionnaire
                                    | newElement =
                                        Question { record | answers =  List.map (\e -> updateAnswer oldQuestionnaire.newAnswer e) record.answers}
                                    --, showNewAnswerModal = False
                                    --, editAnswer = False
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
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    { oldQuestionnaire
                        | newAnswer = element
                        --, showNewAnswerModal = True
                        --, editAnswer = True
                    }
            in
                ( { model | questionnaire = changedQuestionnaire, showNewAnswerModal = True, editAnswer = True }, Cmd.none )

        EditQuestion element ->
            let 
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    { oldQuestionnaire
                        | newElement = element
                        , newCondition = getConditionWithParentID oldQuestionnaire.conditions (getID element)
                        --, showNewQuestionModal = True
                        --, editQElement = True
                    }
            in
                ( { model | questionnaire = changedQuestionnaire, showNewQuestionModal = True, editQElement = True }, Cmd.none )

        EditNote element ->
            let 
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    { oldQuestionnaire
                    | newElement = element
                    --, showNewNoteModal = True
                    --, editQElement = True
                    }
            in
               ( { model | questionnaire = changedQuestionnaire, showNewNoteModal = True, editQElement = True }, Cmd.none )  

        EditQuestionnaire ->
            ( { model | upload = False, editQuestionnaire = True }, Cmd.none )

        --Change order of elements
        PutDownEl element ->
            let
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    if (getID element) /= ((List.length oldQuestionnaire.elements) - 1) then
                        { oldQuestionnaire 
                            | elements = putElementDown oldQuestionnaire.elements element 
                            , conditions = updateConditionWithIdTo oldQuestionnaire.conditions (getID element) ((getID element ) + 1)}
                    else 
                        oldQuestionnaire
            in
                 ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        PutUpEl element ->
            let 
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    if (getID element) /= 0 then
                        { oldQuestionnaire 
                        | elements = putElementUp oldQuestionnaire.elements element 
                        , conditions = updateConditionWithIdTo oldQuestionnaire.conditions (getID element) ((getID element ) - 1)
                        }
                    else 
                        oldQuestionnaire
            in
                 ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        PutUpAns answer ->
            let
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    if answer.id /= 0 then
                        { oldQuestionnaire 
                            | newElement = putAnswerUp oldQuestionnaire.newElement answer
                            , conditions = updateConditionAnswers oldQuestionnaire.conditions answer.id (answer.id - 1)
                        }
                    else 
                        oldQuestionnaire
            in
                 ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        PutDownAns answer ->
            let
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    if answer.id /= ((List.length (getAntworten oldQuestionnaire.newElement)) - 1) then
                        { oldQuestionnaire | newElement = putAnswerDown oldQuestionnaire.newElement answer }
                    else 
                        oldQuestionnaire
            in
                 ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        --Delete existing elements or answers
        DeleteItem element ->
            let
                oldQuestionnaire = model.questionnaire 
                changedQuestionnaire = 
                    { oldQuestionnaire 
                        | elements = deleteItemFrom element oldQuestionnaire.elements
                        , conditions = deleteConditionWithElement oldQuestionnaire.conditions (getID element)
                    }
            in
                ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        DeleteAnswer answer ->
            let 
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    { oldQuestionnaire 
                        | newElement = deleteAnswerFromItem answer oldQuestionnaire.newElement
                        , conditions = List.map (deleteAnswerInCondition answer.id) oldQuestionnaire.conditions
                    }
            in
                ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        -- validate inputs on submit and then save changes
        Submit ->
            let 
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                        { oldQuestionnaire
                            | editTime = model.inputEditTime
                            , viewingTimeBegin = model.inputViewingTimeBegin
                            , viewingTimeEnd = model.inputViewingTimeEnd
                        }
            in
                if validate model == ValidationOK then
                    ( { model 
                        | questionnaire = changedQuestionnaire
                        , showViewingTimeModal = False
                        , showEditTimeModal = False
                        , validationResult = ValidationOK
                      }
                    , Cmd.none )  
                else
                    ( { model 
                        | validationResult = validate model
                        , inputViewingTimeBegin = ""
                        , inputViewingTimeEnd = ""
                        , inputEditTime = ""
                      }
                    , Cmd.none )          

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
                oldQuestionnaire = model.questionnaire
                changedQuestionnaire =
                    { oldQuestionnaire
                        | title = decodeTitle content
                        , elements = decodeElements content
                        --, upload = False
                        --, editQuestionnaire = True
                    }
            in
                ( { model | questionnaire = changedQuestionnaire, upload = False, editQuestionnaire = True }, Cmd.none )

        --Everything releated to download
        DownloadQuestionnaire ->
            ( model, save model.questionnaire (encodeQuestionnaire model.questionnaire) )
    

--View


view : Model -> Html Msg
view model =
    div []
        [ showNavbar
        , if model.upload then
            showUpload model

          else
            showEditQuestionnaire model
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


showNavbar : Html Msg
showNavbar =
    nav [ class "navbar is-link is-fixed-top" ]
        [ div [ class "navbar-brand" ]
            [ p [ class "navbar-item", style "padding-top" "0.5em" ] [ text "Fragebogengenerator" ] ]
        , div [ class "navbar-menu" ]
            [ div [ class "navbar-start" ]
                [ a [ class "navbar-item", onClick EditQuestionnaire ] [ text "Fragebogen Erstellen" ]
                , a [ class "navbar-item", onClick EnterUpload ] [ text "Fragebogen Hochladen" ]
                ]
            ]
        ]


showUpload : Model -> Html Msg
showUpload model =
    div []
        [ showHeroWith "Upload"
        , br [] []
        , div [ class "columns has-text-centered" ]
            [ div [ class "column" ]
                [ button [ onClick JsonRequested ] [ text "Datei auswählen" ]
                ]
            ]
        ]
