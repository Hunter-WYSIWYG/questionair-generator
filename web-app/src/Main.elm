module Main exposing (..)

import Browser
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Html exposing (Html, a, br, button, div, footer, form, h1, header, i, input, label, nav, option, p, section, select, table, tbody, thead, td, text, th, tr)
import Html.Attributes exposing (class, href, id, maxlength, minlength, multiple, name, placeholder, selected, style, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Json.Encode as Encode exposing (encode, object)
import List exposing (append)
import List.Extra exposing (swapAt, updateAt)
import Task
import QEncoder exposing (..)
import QDecoder exposing (..)
import Questionnaire exposing (..)


main =
    Browser.element
        { init = initModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--types


type
    Msg
    --Changing Input
    = ChangeInputQuestionnaireTitle String
    | ChangeEditTime String
    | ChangeViewingTimeBegin String
    | ChangeViewingTimeEnd String
    | ChangeQuestionOrNoteText String
    | ChangeAnswerText String                       
    | ChangeQuestionNote String
    | ChangeQuestionType String
    | ChangeAnswerType String     
    | ChangeQuestionNewAnswer Answer   
    | ChangeQuestionTime String           
    --Modals
    | ViewOrClose ModalType
    --Creates Condition
    | AddCondition String
    | AddConditionAnswer
    | AddAnswerToNewCondition String
    --Save input to questionnaire
    | SetQuestionnaireTitle
    | SetNote
    | SetQuestion
    | SetAnswer                       
    | SetPolarAnswers String
    --Edit existing elements or answers
    | EditQuestion Q_element
    | EditNote Q_element
    | EditAnswer Answer
    | EditQuestionnaire
    --Change order of elements
    | PutUpEl Q_element
    | PutDownEl Q_element
    | PutUpAns Answer
    | PutDownAns Answer
    --Delete existing elements or answers
    | DeleteItem Q_element
    | DeleteAnswer Answer
    --Validation of times
    | Submit
    --Everything releated to upload
    | LeaveOrEnterUpload
    | EnterUpload
    | JsonRequested
    | JsonSelected File
    | JsonLoaded String
    --Everything releated to download
    | DownloadQuestionnaire


type ModalType
    = ViewingTimeModal
    | EditTimeModal
    | NewNoteModal
    | QuestionModal
    | TitleModal
    | AnswerModal


type alias Model =
    { questionnaire : Questionnaire 

    --modals
    , showTitleModal : Bool
    , showEditTimeModal : Bool
    , showViewingTimeModal : Bool
    , showNewNoteModal : Bool
    , showNewQuestionModal : Bool
    , showNewAnswerModal : Bool

    --editQElement for EditQuestion and EditNote
    , editQElement : Bool
    , editAnswer : Bool

    --new inputs
    , inputTitle : String
    , validationResult : ValidationResult
    , inputEditTime : String
    , inputViewingTimeBegin : String
    , inputViewingTimeEnd : String
    , inputQuestionTime : String
    , questionValidationResult : ValidationResult

    --upload determines if the users wants to upload a questionnaire
    --if upload is false show UI to create new questionnaire
    , upload : Bool

    -- a page to edit Questionnaires
    , editQuestionnaire : Bool

    --Debug 
    , tmp : String 
    }


type ValidationResult
    = NotDone
    | Error String
    | ValidationOK


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


-- Input Validation


validate : Model -> ValidationResult
validate model =
    if not (isValidEditTime model.inputEditTime) then
        Error "Die Bearbeitungszeit muss das Format HH:MM haben"

    else if not (isValidViewingTime model.inputViewingTimeBegin) then
        Error "Die Zeiten müssen das Format DD:MM:YYYY:HH:MM haben"

    else if not (isValidViewingTime model.inputViewingTimeEnd) then
        Error "Die Zeiten müssen das Format DD:MM:YYYY:HH:MM haben"
    else
        ValidationOK

isValidViewingTime : String -> Bool
isValidViewingTime viewingTime =
    not (String.length viewingTime /= 16 && String.length viewingTime /= 0)


isValidEditTime : String -> Bool
isValidEditTime editTime =
    not (String.length editTime /= 5 && String.length editTime /= 0)

validateQuestion : String -> ValidationResult
validateQuestion questionTime =
            if not (isValidQuestionTime questionTime) then
                Error "Die Zeiten müssen das Format HH:MM:SS haben"
            else
                ValidationOK

isValidQuestionTime : String -> Bool
isValidQuestionTime questionTime = 
    not (String.length questionTime /= 8 && String.length questionTime /= 0)
    

--View


view : Model -> Html Msg
view model =
    div []
        [ showNavbar
        , if model.upload then
            showUpload model

          else if model.editQuestionnaire then
            showEditQuestionnaire model

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

viewConditions : Questionnaire -> Html Msg
viewConditions questionnaire = 
    div[] (List.map (\c -> text ("("++String.fromInt c.parent_id++","++String.fromInt c.child_id++")")) questionnaire.conditions)


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


-- Show input for bipolar and unipolar Question


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



--radio button control


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



--Table of Answers


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


--Error Message for viewTime and editTime modals


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
