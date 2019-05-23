module Main exposing (..)

import Browser exposing (sandbox)
import Html exposing (Html, button, div, text, table, td, th, tr)
import Html.Attributes exposing (class, id)
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
    [ table [ class "table is-striped" ] (fragenTable fragebogen)
    ]

fragenTable : Fragebogen -> List (Html Msg)
fragenTable fragebogen =
    append [ tableHead ] (List.indexedMap getTable fragebogen.elements)

tableHead : Html Msg
tableHead =
    tr [] [ 
        th [] [ 
            text "id" 
        ], 
        th [] [ 
            text "Foo" 
        ], 
        th [] [ 
            text "Bar" 
        ]
    ]

getTable : Int -> FB_element -> Html msg
getTable index element =
    case element of
        Anmerkung a ->
            tr [ id (String.fromInt index) ]
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text "foo" ]
                , td [] [ text "bar" ]
                ]

        Frage f->
            tr [ id (String.fromInt index) ]
                [ td [] [ text (String.fromInt index) ]
                , td [] [ text "foo" ]
                , td [] [ text "bar" ]
                ]

