module Upload exposing (showUpload)

import Html exposing (Html, br, button, div, h1, section, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (..)


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


showHeroWith : String -> Html Msg
showHeroWith string =
    section [ class "hero is-primary" ]
        [ div [ class "hero-body" ]
            [ div [ class "container is-fluid" ]
                [ h1 [ class "title" ] [ text string ]
                ]
            ]
        ]
