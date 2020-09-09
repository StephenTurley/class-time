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
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    { time : Time.Posix
    , zone : Time.Zone
    , schedule : List Event
    }


type alias Event =
    { title : String
    , url : String
    , startHour : Int
    , startMinute : Int
    , durationInMinutes : Int
    }



-- MSG


type Msg
    = Tick Time.Posix
    | SetTimeZone Time.Zone



-- init


init : () -> ( Model, Cmd Msg )
init _ =
    ( { time = Time.millisToPosix 0
      , zone = Time.utc
      , schedule = []
      }
    , Task.perform SetTimeZone Time.here
    )



-- update


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Tick time ->
            ( { model | time = time }, Cmd.none )

        SetTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )



-- view


view : Model -> Document msg
view model =
    { title = "Class Time"
    , body =
        [ h2 [] [ text "Today's schedule" ]
        , p [] [ strong [] [ text "Current Time: " ], text (humanTime model.zone model.time) ]
        , div [] [ ul [] (List.map eventItem model.schedule) ]
        ]
    }


eventItem : Event -> Html msg
eventItem event =
    li []
        [ a [ href event.url ] [ text event.title ]

        -- , p [] [ strong [] [ text "Start Time " ], text (humanTime event.startTime) ]
        -- , p [] [ strong [] [ text "End Time " ], text (humanTime event.endTime) ]
        ]


humanTime : Time.Zone -> Time.Posix -> String
humanTime zone time =
    let
        hour =
            String.fromInt (Time.toHour zone time)

        minute =
            String.fromInt (Time.toMinute zone time)

        second =
            String.fromInt (Time.toSecond zone time)
    in
    hour ++ ":" ++ minute ++ ":" ++ second



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick
