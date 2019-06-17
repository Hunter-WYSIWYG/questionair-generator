module Main exposing (..)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, a, br, button, div, footer, form, h1, header, i, input, label, nav, p, section, table, tbody, thead, td, text, th, tr)
import Html.Attributes exposing (class, href, id, maxlength, minlength, multiple, name, placeholder, style, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode exposing (encode, object)
import List exposing (append)
import Task


main =
    Browser.element
        { init = initQuestionnaire
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--types


type
    Msg
    --Changing Input
    = ChangeQuestionnaireTitle String
    | ChangeEditTime String
    | ChangeViewingTimeBegin String
    | ChangeViewingTimeEnd String
    | ChangeQuestionOrNoteText String
    | ChangeAnswerText String                       
    | ChangeQuestionNote String
    | ChangeQuestionType String
    | ChangeAnswerType String                       
      --Modals
    | ViewOrClose ModalType
      --Other
    | SetNote
    | SetQuestion
    | SetAnswer                       
    | SetPolarAnswers String
    | EditQuestion Q_element
    | EditNote Q_element
    | DeleteItem Q_element
    | EditAnswer Answer
    | ChangeQuestionNewAnswer Answer
    | DeleteAnswer Answer
    | Submit
    | EditQuestionnaire
    | LeaveOrEnterUpload
    | EnterUpload
    | JsonRequested
    | JsonSelected File
    | JsonLoaded String
    | DownloadQuestionnaire


type ModalType
    = ViewingTimeModal
    | EditTimeModal
    | NewNoteModal
    | QuestionModal
    | TitleModal
    | AnswerModal


type alias Questionnaire =
    { title : String
    , elements : List Q_element

    --times
    , viewingTimeBegin : String
    , viewingTimeEnd : String
    , editTime : String

    --modals
    , showTitleModal : Bool
    , showEditTimeModal : Bool
    , showViewingTimeModal : Bool
    , showNewNoteModal : Bool
    , showNewQuestionModal : Bool
    , showNewAnswerModal : Bool

    --newInputs
    , validationResult : ValidationResult
    , inputEditTime : String
    , inputViewingTimeBegin : String
    , inputViewingTimeEnd : String
    , newElement : Q_element
    , newAnswer : Answer

    --editMode for EditQuestion and EditNote
    , editMode : Bool

    --upload determines if the users wants to upload a questionnaire
    --if upload is false show UI to create new questionnaire
    , upload : Bool

    -- a page to edit Questionnaires
    , editQuestionnaire : Bool

    --Debug
    , tmp : String
    }


type Q_element
    = Note NoteRecord
    | Question QuestionRecord


type alias NoteRecord =
    { id : Int
    , text : String
    }


type alias QuestionRecord =
    { id : Int
    , text : String
    , answers : List Answer
    , hint : String
    , typ : String
    }


type alias Answer =
    { id : Int
    , text : String

    --type can be "free" or "regular"
    , typ : String
    }


type ValidationResult
    = NotDone
    | Error String
    | ValidationOK



-- SUBSCRIPTIONS


subscriptions : Questionnaire -> Sub Msg
subscriptions model =
    Sub.none



--Init


initQuestionnaire : () -> ( Questionnaire, Cmd Msg )
initQuestionnaire _ =
    ({ title = "Titel eingeben"
    , elements = []

    --times
    , viewingTimeBegin = ""
    , viewingTimeEnd = ""
    , editTime = ""

    --modals
    , showTitleModal = False
    , showViewingTimeModal = False
    , showEditTimeModal = False
    , showNewNoteModal = False
    , showNewQuestionModal = False
    , showNewAnswerModal = False

    --new inputs
    , validationResult = NotDone
    , inputViewingTimeBegin = ""
    , inputViewingTimeEnd = ""
    , inputEditTime = ""
    , newElement = initQuestion
    , newAnswer = initAnswer

    --editMode
    , editMode = False
    , editQuestionnaire = True
    , upload = False

    --Debug
    , tmp = ""
    }
    , Cmd.none)


initQuestion : Q_element
initQuestion =
    Question
        { id = 0
        , text = "Beispielfrage"
        , answers = []
        , hint = ""
        , typ = ""
        }

initAnswer : Answer
initAnswer =
    { id = 0
    , text = ""
    --type can be "free" or "regular"
    , typ = ""
    }

--Update logic


update : Msg -> Questionnaire -> ( Questionnaire, Cmd Msg )
update msg questionnaire =
    case msg of
        --changing properties of questionnaire
        ChangeQuestionnaireTitle newTitle ->
            ( { questionnaire | title = newTitle }, Cmd.none )

        ChangeEditTime newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputEditTime = newTime
                    }
            in
            ( { changedQuestionnaire
                | validationResult = validate changedQuestionnaire
              }
            , Cmd.none
            )

        ChangeViewingTimeBegin newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputViewingTimeBegin = newTime
                    }
            in
            ( { changedQuestionnaire
                | validationResult = validate changedQuestionnaire
              }
            , Cmd.none
            )

        ChangeViewingTimeEnd newTime ->
            let
                changedQuestionnaire =
                    { questionnaire
                        | inputViewingTimeEnd = newTime
                    }
            in
            ( { changedQuestionnaire
                | validationResult = validate changedQuestionnaire
              }
            , Cmd.none
            )

        DeleteItem element ->
            ({ questionnaire | elements = deleteItemFrom element questionnaire.elements }, Cmd.none)

        --changing properties of notes or questions
        ChangeQuestionOrNoteText string ->
            let
                changedRecord rec =
                    { rec | text = string }
            in
            case questionnaire.newElement of
                Question record ->
                    ( { questionnaire | newElement = Question (changedRecord record) }, Cmd.none )

                Note record ->
                    ( { questionnaire | newElement = Note (changedRecord record) }, Cmd.none )

        ChangeQuestionNewAnswer newAnswer ->
            case questionnaire.newElement of
                Question record ->
                    ( { questionnaire
                        | newElement =
                            Question
                                { record | answers = record.answers ++ [ newAnswer ] }
                      }
                    , Cmd.none
                    )

                Note record ->
                    ( questionnaire, Cmd.none )

        ChangeQuestionNote string ->
            case questionnaire.newElement of
                Question record ->
                    ( { questionnaire
                        | newElement =
                            Question
                                { record | hint = string }
                      }
                    , Cmd.none
                    )

                Note record ->
                    ( questionnaire, Cmd.none )

        ChangeQuestionType string ->
            case questionnaire.newElement of
                Question record ->
                    ( { questionnaire
                        | newElement =
                            Question
                                { record | typ = string, answers = setPredefinedAnswers string }
                      }
                    , Cmd.none
                    )

                Note record ->
                    ( questionnaire, Cmd.none )


        --changing properties of answers
        ChangeAnswerText string ->
            ({ questionnaire | newAnswer = Answer questionnaire.newAnswer.id string questionnaire.newAnswer.typ }, Cmd.none)     

        ChangeAnswerType string ->
            ({ questionnaire
                | newAnswer =
                    Answer questionnaire.newAnswer.id questionnaire.newAnswer.text string
            }, Cmd.none)

        --open or close modals
        ViewOrClose modalType ->
            case modalType of
                TitleModal ->
                    ( { questionnaire | showTitleModal = not questionnaire.showTitleModal }, Cmd.none )

                ViewingTimeModal ->
                    ( { questionnaire | showViewingTimeModal = not questionnaire.showViewingTimeModal }, Cmd.none )

                EditTimeModal ->
                    ( { questionnaire | showEditTimeModal = not questionnaire.showEditTimeModal }, Cmd.none )

                NewNoteModal ->
                    let
                        changedQuestionnaire =
                            { questionnaire | showNewNoteModal = not questionnaire.showNewNoteModal }
                    in
                    if changedQuestionnaire.showNewNoteModal == True then
                        ( { changedQuestionnaire
                            | newElement =
                                Note
                                    { id = List.length questionnaire.elements
                                    , text = ""
                                    }
                          }
                        , Cmd.none
                        )

                    else
                        ( changedQuestionnaire, Cmd.none )

                QuestionModal ->
                    let
                        changedQuestionnaire =
                            { questionnaire | showNewQuestionModal = not questionnaire.showNewQuestionModal }
                    in
                    if changedQuestionnaire.showNewQuestionModal == True then
                        ( { changedQuestionnaire
                            | newElement =
                                Question
                                    { id = List.length questionnaire.elements
                                    , text = ""
                                    , answers = []
                                    , hint = ""
                                    , typ = ""
                                    }
                          }
                        , Cmd.none
                        )

                    else
                        ( changedQuestionnaire, Cmd.none )

                AnswerModal ->
                    let
                        changedQuestionnaire =
                            { questionnaire | showNewAnswerModal = not questionnaire.showNewAnswerModal }
                    in
                    if changedQuestionnaire.showNewAnswerModal == True then
                        ({ changedQuestionnaire
                            | newAnswer =
                                    { id = (List.length (getAntworten questionnaire.newElement))
                                    , text = ""
                                    --type can be "free" or "regular"
                                    , typ = ""
                                    }
                        }, Cmd.none)

                    else
                        (changedQuestionnaire, Cmd.none)

        DeleteAnswer answer ->
            ({ questionnaire | newElement = deleteAnswerFromItem answer questionnaire.newElement }, Cmd.none)

        --Other

        -- validate inputs on submit and then save changes
        Submit ->
            if validate questionnaire == ValidationOK then
                ( { questionnaire
                    | validationResult = ValidationOK
                    , showViewingTimeModal = False
                    , showEditTimeModal = False
                    , editTime = questionnaire.inputEditTime
                    , viewingTimeBegin = questionnaire.inputViewingTimeBegin
                    , viewingTimeEnd = questionnaire.inputViewingTimeEnd
                  }
                , Cmd.none
                )

            else
                ( { questionnaire
                    | validationResult = validate questionnaire
                    , inputViewingTimeBegin = ""
                    , inputViewingTimeEnd = ""
                    , inputEditTime = ""
                  }
                , Cmd.none
                )

        SetPolarAnswers string ->
            case questionnaire.newElement of
                Question record ->
                    if record.typ == "Skaliert unipolar" then
                        ( { questionnaire | newElement = Question { record | answers = getUnipolarAnswers string } }, Cmd.none )

                    else
                        ( { questionnaire | newElement = Question { record | answers = getBipolarAnswers string } }, Cmd.none )

                Note record ->
                    ( questionnaire, Cmd.none )

        SetNote ->
            if questionnaire.editMode == False then
                ( { questionnaire
                    | elements = append questionnaire.elements [ questionnaire.newElement ]
                    , showNewNoteModal = False
                  }
                , Cmd.none
                )

            else
                ( { questionnaire
                    | elements = List.map (\e -> updateElement questionnaire.newElement e) questionnaire.elements
                    , showNewNoteModal = False
                    , editMode = False
                  }
                , Cmd.none
                )

        SetQuestion ->
            if questionnaire.editMode == False then
                ( { questionnaire
                    | elements = append questionnaire.elements [ questionnaire.newElement ]
                    , showNewQuestionModal = False
                  }
                , Cmd.none
                )

            else
                ( { questionnaire
                    | elements = List.map (\e -> updateElement questionnaire.newElement e) questionnaire.elements
                    , showNewQuestionModal = False
                    , editMode = False
                  }
                , Cmd.none
                )

        SetAnswer ->                                                                    
            case questionnaire.newElement of
                Question record ->
                    ({ questionnaire
                        | newElement =
                            Question { record | answers = record.answers ++ [ questionnaire.newAnswer ] }
                        , showNewAnswerModal = False
                    }, Cmd.none)

                Note record ->
                    (questionnaire, Cmd.none)     

        EditAnswer element ->
            ({ questionnaire
                | newAnswer = element
                , showNewAnswerModal = True
            }, Cmd.none)

        --Edits already existing elements
        EditQuestion element ->
            ( { questionnaire
                | newElement = element
                , showNewQuestionModal = True
                , editMode = True
              }
            , Cmd.none
            )

        EditNote element ->
            ( { questionnaire
                | newElement = element
                , showNewNoteModal = True
                , editMode = True
              }
            , Cmd.none
            )

        EnterUpload ->
            ( { questionnaire
                | upload = True
              }
            , Cmd.none
            )

        LeaveOrEnterUpload ->
            ( { questionnaire
                | upload = not questionnaire.upload
              }
            , Cmd.none
            )

        EditQuestionnaire ->
            ( { questionnaire | upload = False, editQuestionnaire = True }, Cmd.none )

        --Json
        JsonRequested ->
            ( questionnaire
            , Select.file [ "text/json" ] JsonSelected
            )

        JsonSelected file ->
            ( questionnaire
            , Task.perform JsonLoaded (File.toString file)
            )

        JsonLoaded content ->
            ( { questionnaire
                | title = decodeTitle content
                , elements = decodeElements content
              }
            , Cmd.none
            )

        DownloadQuestionnaire ->
            ( { questionnaire | tmp = encodeQuestionnaire questionnaire }, Cmd.none )



-- extracts the title of the questionnaire


decodeTitle : String -> String
decodeTitle content =
    case Decode.decodeString (Decode.field "title" Decode.string) content of
        Ok val ->
            val

        Err e ->
            ""



--extracts the elements (notes, questions) of the questionnaire


decodeElements : String -> List Q_element
decodeElements content =
    case Decode.decodeString (Decode.at [ "elements" ] (Decode.list elementDecoder)) content of
        Ok elements ->
            elements

        Err e ->
            []



--decodes the elements either to a note, or to a question


elementDecoder : Decode.Decoder Q_element
elementDecoder =
    Decode.oneOf [ questionDecoder, noteDecoder ]



--decodes a note


noteDecoder : Decode.Decoder Q_element
noteDecoder =
    Decode.map2 NoteRecord
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        |> Decode.map Note



--decodes a question


questionDecoder : Decode.Decoder Q_element
questionDecoder =
    Decode.map5 QuestionRecord
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "answers" (Decode.list answerDecoder))
        (Decode.field "hint" Decode.string)
        (Decode.field "question_type" Decode.string)
        |> Decode.map Question



--decodes a answer


answerDecoder : Decode.Decoder Answer
answerDecoder =
    Decode.map3 Answer
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "_type" Decode.string)



--encodes questionnaire as a json


encodeQuestionnaire : Questionnaire -> String
encodeQuestionnaire questionnaire =
    encode 4
        (object
            [ ( "title", Encode.string questionnaire.title )
            , ( "elements", Encode.list elementEncoder questionnaire.elements )
            ]
        )



--encodes Q_element


elementEncoder : Q_element -> Encode.Value
elementEncoder element =
    case element of
        Note record ->
            object
                [ ( "_type", Encode.string "Note" )
                , ( "id", Encode.int record.id )
                , ( "text", Encode.string record.text )
                ]

        Question record ->
            object
                [ ( "_type", Encode.string "Question" )
                , ( "id", Encode.int record.id )
                , ( "text", Encode.string record.text )
                , ( "hint", Encode.string record.hint )
                , ( "question_type", Encode.string record.typ )
                , ( "answers", Encode.list answerEncoder record.answers )
                ]



--encodes answers


answerEncoder : Answer -> Encode.Value
answerEncoder answer =
    object
        [ ( "id", Encode.int answer.id )
        , ( "text", Encode.string answer.text )
        , ( "_type", Encode.string answer.typ )
        ]


getAntworten : Q_element -> List Answer                            
getAntworten element =
    case element of
        Question record ->
            record.answers

        Note record ->
            []

setPredefinedAnswers : String -> List Answer
setPredefinedAnswers questionType =
    if questionType == "Ja/Nein Frage" then
        [ regularAnswer 0 "Ja", regularAnswer 1 "Nein" ]

    else
        []


regularAnswer : Int -> String -> Answer
regularAnswer int string =
    { id = int
    , text = string
    , typ = "regular"
    }

freeAnswer : Int -> String -> Answer                                        
freeAnswer int string = 
    { id = int
    , text = string
    , typ = "free" 
    }


getUnipolarAnswers : String -> List Answer
getUnipolarAnswers string =
    case String.toInt string of
        Nothing ->
            []

        Just val ->
            getAnswersWithRange 1 val 0


getBipolarAnswers : String -> List Answer
getBipolarAnswers string =
    case String.toInt string of
        Nothing ->
            []

        Just val ->
            getAnswersWithRange -val val 0


getAnswersWithRange : Int -> Int -> Int -> List Answer
getAnswersWithRange begin end index =
    if begin == end then
        [ regularAnswer index (String.fromInt end) ]

    else
        [ regularAnswer index (String.fromInt begin) ] ++ getAnswersWithRange (begin + 1) end (index + 1)


updateElementList : Q_element -> List Q_element -> List Q_element
updateElementList elementToUpdate list =
    List.map (updateElement elementToUpdate) list

updateAnswerList : Answer -> List Answer -> List Answer
updateAnswerList answerToUpdate list =
    List.map (updateAnswer answerToUpdate) list

updateElement elementToUpdate element =
    if getID element == getID elementToUpdate then
        elementToUpdate

    else
        element

updateAnswer answerToUpdate answer =
    if getAnswerID answer == getAnswerID answerToUpdate then
        answerToUpdate

    else
        answer

getID : Q_element -> Int
getID element =
    case element of
        Question record ->
            record.id

        Note record ->
            record.id

getAnswerID : Answer -> Int
getAnswerID answer = answer.id



deleteItemFrom : Q_element -> List Q_element -> List Q_element
deleteItemFrom element list =
    Tuple.first (List.partition (\e -> e /= element) list)

deleteAnswerFromItem : Answer -> Q_element -> Q_element
deleteAnswerFromItem answer element =
    case element of 
        Question record ->
            Question { record | answers = Tuple.first (List.partition (\e -> e /= answer) record.answers) }
        Note record ->
            Note record

-- Input Validation


validate : Questionnaire -> ValidationResult
validate questionnaire =
    if not (isValidEditTime questionnaire.inputEditTime) then
        Error "Die Bearbeitungszeit muss das Format HH:MM haben"

    else if not (isValidViewingTime questionnaire.inputViewingTimeBegin) then
        Error "Die Zeiten müssen das Format DD:MM:YYYY:HH:MM haben"

    else if not (isValidViewingTime questionnaire.inputViewingTimeEnd) then
        Error "Die Zeiten müssen das Format DD:MM:YYYY:HH:MM haben"

    else
        ValidationOK


isValidViewingTime : String -> Bool
isValidViewingTime viewingTime =
    not (String.length viewingTime /= 16 && String.length viewingTime /= 0)


isValidEditTime : String -> Bool
isValidEditTime editTime =
    not (String.length editTime /= 5 && String.length editTime /= 0)



-- getters for input boxes


getElementText : Q_element -> String
getElementText element =
    case element of
        Question record ->
            record.text

        Note record ->
            record.text

getAnswerText : Answer -> String                                           
getAnswerText answer = answer.text


getQuestionHinweis : Q_element -> String
getQuestionHinweis element =
    case element of
        Question record ->
            record.hint

        Note record ->
            "None"


getQuestionTyp : Q_element -> String
getQuestionTyp element =
    case element of
        Question record ->
            record.typ

        Note record ->
            "None"

getAnswerType : Answer -> String                                            
getAnswerType answer = answer.typ



--View


view : Questionnaire -> Html Msg
view questionnaire =
    div []
        [ showNavbar
        , if questionnaire.upload then
            showUpload questionnaire

          else if questionnaire.editQuestionnaire then
            showEditQuestionnaire questionnaire

          else
            showEditQuestionnaire questionnaire
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
            [ h1 [ style "vertical-align" "middle", class "navbar-item title is-4" ] [ text "Fragebogengenerator" ] ]
        , div [ class "navbar-menu" ]
            [ div [ class "navbar-start" ]
                [ a [ class "navbar-item", onClick EditQuestionnaire ] [ text "Fragebogen Erstellen" ]
                , a [ class "navbar-item", onClick EnterUpload ] [ text "Fragebogen Hochladen" ]
                ]
            ]
        ]


showUpload : Questionnaire -> Html Msg
showUpload questionnaire =
    div []
        [ showHeroWith "Upload"
        , br [] []
        , div [ class "columns has-text-centered" ]
            [ div [ class "column" ]
                [ button [ onClick JsonRequested ] [ text "Datei auswählen" ]
                ]
            ]
        , text questionnaire.tmp
        ]


showEditQuestionnaire : Questionnaire -> Html Msg
showEditQuestionnaire questionnaire =
    div []
        [ showHeroQuestionnaireTitle questionnaire
        , showQuestionList questionnaire
        , showTimes questionnaire
        , showCreateQuestionOrNoteButtons questionnaire
        , viewTitleModal questionnaire
        , viewEditTimeModal questionnaire
        , viewViewingTimeModal questionnaire
        , viewNewNoteModal questionnaire
        , viewNewQuestionModal questionnaire
        , viewNewAnswerModal questionnaire
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
        , text questionnaire.tmp
        ]



-- Show Viewing time and Edit time


getViewingTime : Questionnaire -> String
getViewingTime questionnaire =
    if questionnaire.editTime == "" then
        "unbegrenzt"

    else
        questionnaire.editTime


getEditTime : Questionnaire -> String
getEditTime questionnaire =
    if questionnaire.viewingTimeBegin == "" then
        "unbegrenzt"

    else
        "Von " ++ questionnaire.viewingTimeBegin ++ " Bis " ++ questionnaire.viewingTimeEnd



--MODALS


viewViewingTimeModal : Questionnaire -> Html Msg
viewViewingTimeModal questionnaire =
    if questionnaire.showViewingTimeModal then
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
                            , value questionnaire.inputViewingTimeBegin
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
                            , value questionnaire.inputViewingTimeEnd
                            , maxlength 16
                            , minlength 16
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , onInput ChangeViewingTimeEnd
                            ]
                            []
                        ]
                    , br [] []
                    , viewValidation questionnaire
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


viewEditTimeModal : Questionnaire -> Html Msg
viewEditTimeModal questionnaire =
    if questionnaire.showEditTimeModal then
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
                            , value questionnaire.inputEditTime
                            , maxlength 5
                            , minlength 5
                            , style "width" "180px"
                            , style "margin-left" "10px"
                            , style "margin-right" "10px"
                            , onInput ChangeEditTime
                            ]
                            []
                        , br [] []
                        , viewValidation questionnaire
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


viewTitleModal : Questionnaire -> Html Msg
viewTitleModal questionnaire =
    if questionnaire.showTitleModal then
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
                            , value questionnaire.title
                            , onInput ChangeQuestionnaireTitle
                            ]
                            []
                        ]
                    ]
                , footer [ class "modal-card-foot" ]
                    [ button
                        [ class "button is-success"
                        , onClick (ViewOrClose TitleModal)
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


viewNewNoteModal : Questionnaire -> Html Msg
viewNewNoteModal questionnaire =
    if questionnaire.showNewNoteModal then
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


viewNewQuestionModal : Questionnaire -> Html Msg
viewNewQuestionModal questionnaire =
    if questionnaire.showNewQuestionModal then
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
                        , text "hint: "
                        , input
                            [ class "input"
                            , type_ "text"
                            , style "width" "100%"
                            , value (getQuestionHinweis questionnaire.newElement)
                            , onInput ChangeQuestionNote
                            ]
                            []
                        , br [] []
                        , text ("Typ: " ++ getQuestionTyp questionnaire.newElement)
                        , br [] []
                        , radio "Single Choice" (ChangeQuestionType "Single Choice")
                        , radio "Multiple Choice" (ChangeQuestionType "Multiple Choice")
                        , radio "Ja/Nein Frage" (ChangeQuestionType "Ja/Nein Frage")
                        , radio "Skaliert unipolar" (ChangeQuestionType "Skaliert unipolar")
                        , radio "Skaliert bipolar" (ChangeQuestionType "Skaliert bipolar")
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


viewNewAnswerModal : Questionnaire -> Html Msg
viewNewAnswerModal questionnaire =
    if questionnaire.showNewAnswerModal then
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
                            , value (getAnswerText questionnaire.newAnswer)             --getAnswerText, newAnswer
                            , onInput ChangeAnswerText                                  --ChangeAnswerText
                            ]
                            []
                        ]
                    , br [] []
                    , div []
                        [ text ("Typ: " ++ getAnswerType questionnaire.newAnswer)  --getAnswerType, .newAnswer                      
                        , br [] []
                        , radio "Fester Wert" (ChangeAnswerType "Fester Wert")      --ChangeAnswerType
                        , radio "Freie Eingabe" (ChangeAnswerType "Freie Eingabe")   --ChangeAnswerType
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
            if record.typ == "Skaliert unipolar" || record.typ == "Skaliert bipolar" then
                input
                    [ class "input"
                    , type_ "text"
                    , style "width" "100px"
                    , style "margin-left" "10px"
                    , style "margin-top" "2px"
                    , placeholder "Anzahl answers"
                    , onInput SetPolarAnswers
                    ]
                    []

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
             [ text "hint"
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
                        [ class "fas fa-cog"
                        , onClick (EditNote element)
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
                        [ class "fas fa-cog"
                        , onClick (EditQuestion element)
                        ]
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
                [ class "fas fa-cog"
                , style "margin-right" "10px"
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


viewValidation : Questionnaire -> Html msg
viewValidation questionnaire =
    let
        ( color, message ) =
            case questionnaire.validationResult of
                NotDone ->
                    ( "", "" )

                Error msg ->
                    ( "red", msg )

                ValidationOK ->
                    ( "green", "OK" )
    in
    div [ style "color" color ] [ text message ]
