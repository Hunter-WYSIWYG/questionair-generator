module Upload exposing (showUpload)

{-| Enthält die View für das Hochladen von Fragebögen.


# Öffentliche Funktionen

@docs showUpload

-}

import Html exposing (Html, br, button, div, h1, section, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (Model, Msg(..))


{-| Zeigt die Oberfläche bzw. die View für das Bearbeiten von Fragebögen an.
-}
showUpload : Model -> Html Msg
showUpload model =
    div []
        [ showHeroWith "Upload"
        , br [] []
        , div [ class "columns has-text-centered" ]
            [ div [ class "column" ]
                [ button [ class "qnButton", onClick JsonRequested ] [ text "Datei auswählen" ]
                ]
            ]
        ]


{-| Zeigt den Titel der Seite in einem Hero an (siehe Bulma.io).
-}
showHeroWith : String -> Html Msg
showHeroWith string =
    section [ class "hero is-info" ]
        [ div [ class "hero-body" ]
            [ div [ class "container is-fluid" ]
                [ h1 [ class "title" ] [ text string ]
                ]
            ]
        ]
