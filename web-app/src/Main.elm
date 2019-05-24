module Main exposing (..)

import Browser exposing (sandbox)
import Html exposing (Html, button, br, div, h1, input, section, text, table, td, th, tr)
import Html.Attributes exposing (class, id, maxlength, placeholder, style, type_)
import Html.Events exposing (onClick)
import List exposing (append)

main =
  Browser.sandbox { init = initFragebogen, view = view, update = update }

--types
type Msg = Increment | Decrement

type alias Fragebogen = 
    {   elements : List FB_element,
        tmp : Int }

type FB_element 
    = Anmerkung {   id : Int, 
                    text : String }

    | Frage {   id : Int, 
                text : String, 
                antworten : List Antwort, 
                hinweis : String, 
                typ : String }

type alias Antwort = 
    {   id : Int,
        text : String,
        typ : String }

--Init
initFragebogen : Fragebogen 
initFragebogen = 
    { elements = [initFrage], tmp = 0 }

--Beispielfrage
initFrage : FB_element
initFrage = 
    Frage {id = 0, text = "Wie geht's?", antworten = [], hinweis = "Das ist eine Frage", typ = "Typ 1"}


--Update logic
update : Msg -> Fragebogen -> Fragebogen
update msg fragebogen =
    case msg of
        Increment ->
            { fragebogen | tmp = fragebogen.tmp + 1 }
        Decrement ->
            { fragebogen | tmp = fragebogen.tmp - 1 }

--View

view : Fragebogen -> Html Msg
view fragebogen =
  div []
    [ section [ class "hero is-primary" ]
        [ div [ class "hero-body" ]
            [
                div [ class "container" ]
                    [ h1 [ class "title" ] [ text "Fragebogen" ]
                    ]
            ]
        ]
    , div [ class "container is-fluid", style "margin-bottom" "10px" ] 
        [ table [ class "table is-striped", style "width" "100%" ] (fragenTable fragebogen) 
        ]
    , div [ class "container", style "margin-bottom" "10px"]
        [ text "Bearbeitungszeit"
        , input [ class "input", type_ "text", placeholder "HH:MM", maxlength 5, style "width" "150px", style "margin-left" "10px", style "margin-bottom" "10px" ] []
        , br [] []
        , text "Erscheinungszeit"
        , input [ class "input", type_ "text", placeholder "DD:MM:YYYY", maxlength 10, style "width" "150px", style "margin-left" "10px" ] []
        ]
    , div [ class "container" ]
        [ button [ style "margin-right" "10px" ] [ text "Neue Frage" ]
        , button [] [ text "Neue Anmerkung"] 
        ]
    ]

fragenTable : Fragebogen -> List (Html Msg)
fragenTable fragebogen =
    append [ tableHead ] (List.indexedMap getTable fragebogen.elements)

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
        Anmerkung a ->
            tr [ id (String.fromInt index) ]
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text a.text ]
                ]

        Frage f->
            tr [ id (String.fromInt index) ]
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text f.text ]
                , td [] [ text f.hinweis ]
                , td [] [ text f.typ ]
                , td [] [ button [ style "margin-right" "10px" ] [ text "B" ]
                        , button [] [ text "L" ] ]
                ]

