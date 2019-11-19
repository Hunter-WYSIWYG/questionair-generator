module Upload exposing (showUpload)

{-| Contains the view for uploading questionnaires.


# Public functions

@docs showUpload

-}

import Html exposing (Html, br, button, div, h1, section, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (Model, Msg(..))


{-| Displays the interface or view for editing questionnaires.
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


{-| Displays the title of the page in a hero (see Bulma.io).
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
