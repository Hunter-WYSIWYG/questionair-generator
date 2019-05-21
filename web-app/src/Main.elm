module Main exposing (..)

import Browser exposing (sandbox)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)

main =
  Browser.sandbox { init = initModel, view = view, update = update }

type Msg = Increment | Decrement

type alias Model = 
    { tmp : Int }

initModel : Model 
initModel = 
    { tmp = 0 }

update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | tmp = model.tmp + 1 }
        Decrement ->
            { model | tmp = model.tmp - 1 }

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text (String.fromInt model.tmp) ]
    , button [ onClick Increment ] [ text "+" ]
    ]
