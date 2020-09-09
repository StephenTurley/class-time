module Main exposing (..)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (href)
import Task exposing (Task)
import Time


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = \cmd -> Sub.none
        }



-- Model


type alias Model =
    List Event


type alias Event =
    { startTime : Time.Posix
    , endTime : Time.Posix
    , url : String
    , title : String
    }



-- init


init : () -> ( Model, Cmd msg )
init _ =
    let
        start =
            Time.millisToPosix 1599673056201

        end =
            Time.millisToPosix (1599673056201 + (60 * 60 * 1000))

        event =
            Event start end "http://zoom.com" "Test"
    in
    ( [ event ], Cmd.none )



-- update


update : msg -> Model -> ( Model, Cmd msg )
update msg model =
    ( model, Cmd.none )



-- view


view : Model -> Document msg
view model =
    { title = "Class Time"
    , body =
        [ h2 [] [ text "Today's schedule" ]
        , div [] [ ul [] (List.map eventItem model) ]
        ]
    }


eventItem : Event -> Html msg
eventItem event =
    li []
        [ a [ href event.url ] [ text event.title ]
        , p [] [ strong [] [ text "Start Time " ], text (humanTime event.startTime) ]
        , p [] [ strong [] [ text "End Time " ], text (humanTime event.endTime) ]
        ]


humanTime : Time.Posix -> String
humanTime time =
    let
        hour =
            String.fromInt (Time.toHour Time.utc time)

        minute =
            String.fromInt (Time.toMinute Time.utc time)
    in
    hour ++ ":" ++ minute
