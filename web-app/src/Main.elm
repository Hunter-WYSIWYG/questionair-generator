port module Main exposing (subscriptions, main, update, view)

{-| Main contains the main features of the WebApp.


# Functions

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
import Json.Encode as JEncode
import Json.Decode as JDecode
import List
import Model exposing (ModalType(..), Model, Msg(..), ValidationResult(..))
import QElement exposing (Q_element(..))
import Questionnaire
import Task
import Upload
import Time exposing (..)


{-| Main function.
-}
main : Program () Model Msg
main =
    Browser.element
        { init = Model.initModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

{-| Port for DateTimePicker
-}
port viewingTime : (String -> msg) -> Sub msg
port reminderTime : (JDecode.Value -> msg) -> Sub msg
port editTime : (String -> msg) -> Sub msg
port enterUpload : () -> Cmd msg
port leaveUpload : () -> Cmd msg
port decodedViewingTime : String -> Cmd msg
port decodedReminderTime : List String -> Cmd msg
port decodedEditTime : String -> Cmd msg


{-| Subscriptions-Function
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [viewingTime ChangeViewingTime, reminderTime ChangeReminderTimes, editTime ChangeEditTime]


{-| Update function with logic of the WebApp.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        --changing properties of notes or questions or answers
        ChangeInputQuestionnaireTitle newTitle ->
            ( { model | inputTitle = newTitle }, Cmd.none )

        ChangeInputPriority newPriority ->
            let 
                priority = Maybe.withDefault 0 ( String.toInt newPriority ) 
            in
                ( { model | inputPriority = priority }, Cmd.none )

        ChangeQuestionOrNoteText string ->
            let
                changedRecord rec =
                    { rec | text = string }

            in
                case model.newElement of
                    Question record ->
                        ( { model | newElement = Question (changedRecord record) }, Cmd.none )

                    Note record ->
                        ( { model | newElement = Note (changedRecord record) }, Cmd.none )

        ChangeQuestionNewAnswer newAnswer ->
            case model.newElement of
                Question record ->
                    ( { model | newElement = Question { record | answers = record.answers ++ [ newAnswer ] } }, Cmd.none )

                Note record ->
                    ( model, Cmd.none )

        ChangeQuestionNote string ->
            case model.newElement of
                Question record ->
                    ( { model | newElement = Question { record | hint = string } }, Cmd.none )

                Note record ->
                    ( model, Cmd.none )

        ChangeQuestionType string ->
            case model.newElement of
                    Question record ->
                        ( { model | newElement =
                            if string == "Ja/Nein Frage" then
                                Question 
                                    { record 
                                        | typ = string
                                        , answers = Answer.getYesNoAnswers string
                                        , tableSize = 0
                                        , topText = ""
                                        , rightText = ""
                                        , leftText = ""
                                        , bottomText = ""
                                        , polarMin = 0
                                        , polarMax = 0  
                                    }
                            else if string == "Single Choice" || string == "Multiple Choice" then
                                Question
                                    { record
                                        | typ = string 
                                        , tableSize = 0
                                        , topText = ""
                                        , rightText = ""
                                        , leftText = ""
                                        , bottomText = ""
                                        , polarMin = 0
                                        , polarMax = 0 
                                    }
                            else
                                Question 
                                    { record 
                                        | typ = string 
                                        , answers = []
                                        , tableSize = 0
                                        , topText = ""
                                        , rightText = ""
                                        , bottomText = ""
                                        , leftText = ""
                                        , polarMin = 0
                                        , polarMax = 0
                                    }
                          }
                        , Cmd.none
                        )

                    Note record ->
                        ( model, Cmd.none )

        ChangeAnswerText string ->
            let
                oldAnswer = model.newAnswer
            in
                ( { model | newAnswer = Answer oldAnswer.id string oldAnswer.typ }, Cmd.none )

        ChangeAnswerType string ->
            let
                oldAnswer = model.newAnswer
            in
                ( { model | newAnswer = Answer oldAnswer.id oldAnswer.text string }, Cmd.none )

        ChangeViewingTime string -> 
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire | viewingTime = string }
            in
                ( { model | questionnaire = changedQuestionnaire }, Cmd.none)

        ChangeEditTime string -> 
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire | editTime = string }
            in
                ( { model | questionnaire = changedQuestionnaire }, Cmd.none)

        ChangeReminderTimes json -> 
            case JDecode.decodeValue (JDecode.list JDecode.string) json  of
                Ok times ->
                    let
                        oldQuestionnaire =
                            model.questionnaire

                        changedQuestionnaire =
                            { oldQuestionnaire | reminderTimes = times }
                    in
                        ( { model | questionnaire = changedQuestionnaire }, Cmd.none)
            
                _ ->
                    (model, Cmd.none)
                    

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
                    in
                        if not model.showNewNoteModal == True then
                            ( { model
                                | newElement = Note { id = List.length oldQuestionnaire.elements, text = "" }
                                , showNewNoteModal = not model.showNewNoteModal
                            }
                            , Cmd.none
                            )
                        else
                            ( { model | showNewNoteModal = not model.showNewNoteModal }, Cmd.none )

                QuestionModal ->
                    let 
                        oldQuestionnaire = model.questionnaire
                    in
                        if not model.showNewQuestionModal == True then
                            ( { model
                                | newElement =
                                    Question
                                        { id = List.length oldQuestionnaire.elements
                                            , text = ""
                                            , answers = []
                                            , hint = ""
                                            , typ = ""
                                            , questionTime = ""
                                            , tableSize = 0
                                            , topText = ""
                                            , rightText = ""
                                            , bottomText = ""
                                            , leftText = ""
                                            , polarMin = 0
                                            , polarMax = 0
                                        }
                                , showNewQuestionModal = not model.showNewQuestionModal
                                , questionValidationResult = NotDone    
                                , inputQuestionTime = ""   
                              }
                            , Cmd.none
                            )
                            else
                                ( { model
                                    | showNewQuestionModal = not model.showNewQuestionModal
                                    , questionValidationResult = NotDone
                                    , inputQuestionTime = ""
                                  }
                                , Cmd.none
                                )

                AnswerModal ->
                    if not model.showNewAnswerModal == True then
                        ( { model | newAnswer =
                            { id = List.length (QElement.getAntworten model.newElement)
                            , text = ""
                            --type can be "free" or "regular"
                            , typ = ""
                            }
                            , showNewAnswerModal = not model.showNewAnswerModal
                          }
                        , Cmd.none
                        )

                    else
                        ( { model | showNewAnswerModal = not model.showNewAnswerModal }, Cmd.none )
                    
                ConditionModalOverview ->
                    let
                        oldQuestionnaire =
                            model.questionnaire

                        changedQuestionnaire =
                            oldQuestionnaire
                    in
                    ( { model | questionnaire = changedQuestionnaire, showNewConditionModalOverview = not model.showNewConditionModalOverview }, Cmd.none )

                ConditionModalCreate ->
                    let
                        oldQuestionnaire =
                            model.questionnaire

                        changedQuestionnaire =
                            oldQuestionnaire
                    in
                    ( { model | questionnaire = changedQuestionnaire, showNewConditionModalCreate = not model.showNewConditionModalCreate }, Cmd.none )

        --Add Condition
        ChangeInputParentId parent_id ->
            let
                oldQuestionnaire = model.questionnaire
                oldCondition = model.newCondition
                newCondition2 = {oldCondition | parent_id = strToInt parent_id }

            in
                ( { model | newCondition = newCondition2 }, Cmd.none )

        --LOOK HERE
        ChangeInputChildId child_id ->
            let
                oldQuestionnaire = model.questionnaire
                oldCondition = model.newCondition
                newCondition2 = { oldCondition | child_id = strToInt child_id }
            in
                ( { model | newCondition = newCondition2 }, Cmd.none )

        ChangeInputAnswerId answer_id ->
            let
                oldQuestionnaire = model.questionnaire
                oldCondition = model.newCondition
                newCondition2 = { oldCondition | answer_id = strToInt answer_id }
            in
                ( { model | newCondition = newCondition2 }, Cmd.none )

        AddAnswerToNewCondition string ->
            ( { model | newAnswerID_Condition = string }, Cmd.none )

        --Save input to questionnaire
        SetQuestionnaireTitlePriority ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire | title = model.inputTitle, priority = model.inputPriority }
            in
            ( { model | questionnaire = changedQuestionnaire, showTitleModal = not model.showTitleModal, inputTitle = "" }, Cmd.none )

        SetPolarMin string ->
            let
                newMin = Maybe.withDefault 0 (String.toInt string )
            in
                case model.newElement of
                    Question record ->
                        if record.typ == "Skaliert bipolar" then
                            ( { model | newElement = Question { record | polarMin = newMin } }, Cmd.none )
                        else
                            ( { model | newElement = Question { record | polarMin = 0 } }, Cmd.none )

                    Note record ->
                        ( model, Cmd.none )
        
        SetPolarMax string ->
            let
                newMax = Maybe.withDefault 0 ( String.toInt string )
            in 
                case model.newElement of 
                    Question record ->
                        if record.typ == "Skaliert unipolar" || record.typ == "Skaliert bipolar" then
                            ( {model | newElement = Question { record | polarMax = newMax } }, Cmd.none )
                        else 
                            ( {model | newElement = Question {record | polarMax = 0 } }, Cmd.none )
                
                    Note record ->
                        ( model, Cmd.none )

        -- Set-function for size of table for questiontype "Raster-Auswahl"
        SetTableSize string ->
            let 
                size = Maybe.withDefault 0 ( String.toInt string ) 
                changedElement =  
                    case model.newElement of 
                        Question record ->
                            Question { record | tableSize = size }
                     
                        Note record ->
                            Note record

            in
                case model.newElement of 
                    Question record ->
                        if record.typ == "Raster-Auswahl" then
                            ( { model | newElement = changedElement }, Cmd.none )
                        else 
                            ( model, Cmd.none )
                
                    Note record ->
                        ( model, Cmd.none )
        
        -- Set-function for label on the top of the table for questiontype "Raster-Auswahl"
        SetTopText string ->
            let
                changedElement =  
                    case model.newElement of 
                        Question record ->
                            Question { record | topText = string }
                     
                        Note record ->
                            Note record
            in 
                case model.newElement of 
                    Question record ->
                        if record.typ == "Raster-Auswahl" then
                            ( { model | newElement = changedElement }, Cmd.none )
                        else 
                            ( model, Cmd.none )

                    Note record ->
                        ( model, Cmd.none )
        
        -- Set-function for label on the right of the table/scale for questiontype "Skaliert uni/bipolar", "Prozentslider, ""Raster-Auswahl"
        SetRightText string ->
            let
                changedElement =  
                    case model.newElement of 
                        Question record ->
                            Question { record | rightText = string }
                    
                        Note record ->
                            Note record
            in 
                case model.newElement of 
                    Question record ->
                        if ( record.typ == "Raster-Auswahl" || record.typ == "Prozentslider" 
                        || record.typ == "Skaliert bipolar" || record.typ == "Skaliert unipolar" ) then
                            ( { model | newElement = changedElement }, Cmd.none )
                        else 
                            ( model, Cmd.none )

                    Note record ->
                        ( model, Cmd.none )
        
        -- Set-function for label on the bottom of the table for questiontype "Raster-Auswahl"
        SetBottomText string ->
            let
                changedElement =  
                    case model.newElement of 
                        Question record ->
                            Question { record | bottomText = string }
                     
                        Note record ->
                            Note record
            in 
                case model.newElement of 
                    Question record ->
                        if record.typ == "Raster-Auswahl" then
                            ( { model | newElement = changedElement }, Cmd.none )
                        else 
                            ( model, Cmd.none )

                    Note record ->
                        ( model, Cmd.none )
        
        -- Set-function for label on the left of the table/scale for questiontype "Skaliert uni/bipolar", "Prozentslider", "Raster-Auswahl"
        SetLeftText string ->
            let
                changedElement =  
                    case model.newElement of 
                        Question record ->
                            Question { record | leftText = string }
                     
                        Note record ->
                            Note record
            in 
                case model.newElement of 
                    Question record ->
                        if ( record.typ == "Raster-Auswahl" || record.typ == "Prozentslider" 
                        || record.typ == "Skaliert bipolar" || record.typ == "Skaliert unipolar" )  then
                            ( { model | newElement = changedElement }, Cmd.none )
                        else 
                            ( model, Cmd.none )

                    Note record ->
                        ( model, Cmd.none )

        SetNote ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    if model.editQElement == False then
                        { oldQuestionnaire
                            | elements = List.append oldQuestionnaire.elements [ model.newElement ]
                        }

                    else
                        { oldQuestionnaire
                            | elements = List.map (\e -> QElement.updateElement model.newElement e) oldQuestionnaire.elements
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
                            | elements = List.append oldQuestionnaire.elements [ model.newElement ] }

                    else
                        { oldQuestionnaire
                            | elements = List.map (\e -> QElement.updateElement model.newElement e) oldQuestionnaire.elements
                            , conditions =
                                if (Condition.validateCondition model.newCondition model.newElement) then
                                    List.map (\e -> Condition.updateCondition model.newCondition e) oldQuestionnaire.conditions

                                else
                                    Condition.removeConditionFromCondList model.newCondition oldQuestionnaire.conditions
                        }
            in
            if model.editQElement == False && (isTypeEmpty model) == False then
                ( { model | questionnaire = changedQuestionnaire, showNewQuestionModal = False, newCondition = Condition.initCondition }, Cmd.none )

            else if (isTypeEmpty model) == False then
                ( { model | questionnaire = changedQuestionnaire, showNewQuestionModal = False, editQElement = False }, Cmd.none )

            else (model, Cmd.none)
                
        SetConditions ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    if model.editCondition == False then
                        { oldQuestionnaire
                            | conditions =
                                List.append oldQuestionnaire.conditions [ model.newCondition ]
                        }

                    else
                        { oldQuestionnaire
                                    | conditions =
                                         List.map (\e -> Condition.updateCondition model.newCondition e) oldQuestionnaire.conditions
                        }
            in
            if model.editCondition == False then
                ( { model | questionnaire = changedQuestionnaire, showNewConditionModalCreate = False, newCondition = (Condition.initCondition) }, Cmd.none )

            else 
                ( { model | questionnaire = changedQuestionnaire, showNewConditionModalCreate = False, editCondition = False , newCondition = (Debug.log "foo" Condition.initCondition) }, Cmd.none )

        SetAnswer ->
            case model.newElement of
                Question record ->
                    if model.editAnswer == False && model.newAnswer.typ /= "" then
                        ( { model |
                            showNewAnswerModal = False
                            , newElement = Question { record | answers = record.answers ++ [ model.newAnswer ] }
                          }
                        , Cmd.none
                        )
                    else if model.newAnswer.typ == "" then
                        ( model, Cmd.none )
                    else
                        ( { model |
                            showNewAnswerModal = False
                            , editAnswer = False
                            , newElement = Question { record | answers = List.map (\e -> Answer.update model.newAnswer e) record.answers }
                          }
                        , Cmd.none
                        )

                Note record ->
                    ( model, Cmd.none )

        --Edits already existing elements
        EditAnswer element ->
            ( { model | newAnswer = element, showNewAnswerModal = True, editAnswer = True }, Cmd.none )

        EditCondition condition ->
            ( { model | newCondition = condition, showNewConditionModalCreate = True, editCondition = True }, Cmd.none )

        EditQuestion element ->
            let
                oldQuestionnaire = model.questionnaire
            in
                (
                    { model
                        | newElement = element
                        , showNewQuestionModal = True
                        , editQElement = True
                    }
                , Cmd.none
                )

        EditNote element ->
            (
                { model
                    | newElement = element
                    , showNewNoteModal = True
                    , editQElement = True
                }
            , Cmd.none
            )

        EditQuestionnaire ->
            ( { model | upload = False, editQuestionnaire = True }, leaveUpload () )

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

                oldElement =
                    model.newElement

                changedQuestionnaire =
                    { oldQuestionnaire |  conditions = Condition.updateConditionAnswers oldQuestionnaire.conditions answer.id (answer.id - 1) }

            in
                if answer.id /= 0 then
                    ( { model | questionnaire = changedQuestionnaire, newElement = QElement.putAnswerUp oldElement answer }, Cmd.none )
                else
                    ( model, Cmd.none )

        PutDownAns answer ->
            let
                oldQuestionnaire =
                    model.questionnaire

                oldElement =
                    model.newElement

                changedQuestionnaire =
                    { oldQuestionnaire |  conditions = Condition.updateConditionAnswers oldQuestionnaire.conditions answer.id (answer.id + 1) }
            in
                if  answer.id /= (List.length (QElement.getAntworten oldElement) - 1) then
                    ( { model | questionnaire = changedQuestionnaire, newElement = QElement.putAnswerDown oldElement answer }, Cmd.none )
                else
                    ( model, Cmd.none )

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

        DeleteCondition condition ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire | conditions = Condition.deleteConditionFrom condition oldQuestionnaire.conditions
                    }
            in
            ( { model | questionnaire = changedQuestionnaire }, Cmd.none )

        DeleteAnswer answer ->
            let
                oldElement = model.newElement

                oldQuestionnaire = model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire | conditions = Condition.deleteConditionUpdate oldQuestionnaire.conditions (QElement.getID oldElement) (Answer.getAnswerId answer) }
            in
            ( { model | questionnaire = changedQuestionnaire, newElement = QElement.deleteAnswerFromItem answer oldElement }, Cmd.none )

        -- validate inputs on submit and then save changes
        Submit ->
            let
                oldQuestionnaire =
                    model.questionnaire

                changedQuestionnaire =
                    { oldQuestionnaire
                        | editTime = model.inputEditTime
                        , viewingTime = model.inputViewingTime
                        , reminderTimes = model.inputReminderTimes
                    }
            in
                ( { model
                    | questionnaire = changedQuestionnaire
                    , showViewingTimeModal = False
                    , showEditTimeModal = False
                    , validationResult = ValidationOK
                  }
                , Cmd.none
                )

        --Everything releated to upload
        EnterUpload ->
            ( { model | upload = True }, enterUpload ())

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
                        , id = Decoder.decodeId content
                        , priority = Decoder.decodePriority content
                        , elements = Decoder.decodeElements content
                        , conditions = Decoder.decodeConditions content
                        , viewingTime = Decoder.decodeViewingTime content
                        , reminderTimes = Decoder.decodeReminderTimes content
                        , editTime = Decoder.decodeEditTime content
                    }
            in
            ( { model | questionnaire = changedQuestionnaire, upload = False, editQuestionnaire = True }
            , Cmd.batch     [ leaveUpload ()
                            , decodedViewingTime (Decoder.decodeViewingTime content)
                            , decodedReminderTime (Decoder.decodeReminderTimes content)
                            , decodedEditTime (Decoder.decodeEditTime content)
                            ] 
            )

        --Everything releated to download
        DownloadQuestionnaire ->
            ( model, Encoder.save model.questionnaire (Encoder.encodeQuestionnaire model.questionnaire) )


{-| Displays the views for editing and uploading questionnaires.
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



{-| Displays a Navbar with options to switch between the views for editing and uploading questionnaires.
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

{-| Extracts the ID of a child or parent of a condition.
-}
extractID : String -> String
extractID id =
    case List.head (String.split "." id) of
        Just realID ->
            realID
        Nothing ->
            "-1"

{-| Converts the ID of a child or parent of a condition to an integer value.
-}
strToInt id =
    case String.toInt (extractID id) of
        Just a ->
            a

        Nothing ->
            -1

{-| Checks whether the type of a Question is empty. Returns true if the newElement is a Note.
-}
isTypeEmpty : Model -> Bool
isTypeEmpty model = 
    case model.newElement of
        Question record ->
            (record.typ == "")
        Note record ->
            True