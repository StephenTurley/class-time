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
    , currentEvent : Maybe Event
    , schedule : List Event
    }


type alias Event =
    { title : String
    , url : String
    , startHour : Int
    , startMinute : Int
    , durationInMinutes : Int
    }


startTime : Model -> Event -> Time.Posix
startTime model event =
    Time.millisToPosix <| startTimeInMillis model event


endTime : Model -> Event -> Time.Posix
endTime model event =
    Time.millisToPosix <| endTimeInMillis model event


startTimeInMillis : Model -> Event -> Int
startTimeInMillis model event =
    let
        hour =
            event.startHour * 60 * 60 * 1000

        minute =
            event.startMinute * 60 * 1000
    in
    startOfDay model.zone model.time + hour + minute


endTimeInMillis : Model -> Event -> Int
endTimeInMillis model event =
    let
        duration =
            event.durationInMinutes * 60 * 1000
    in
    startTimeInMillis model event + duration


startOfDay : Time.Zone -> Time.Posix -> Int
startOfDay zone currentTime =
    let
        currentHour =
            Time.toHour zone currentTime * 60 * 60 * 1000

        currentMinute =
            Time.toMinute zone currentTime * 60 * 1000

        currentSecond =
            Time.toSecond zone currentTime * 1000

        currentMillis =
            Time.toMillis zone currentTime
    in
    Time.posixToMillis currentTime - currentHour - currentMinute - currentSecond - currentMillis



-- MSG


type Msg
    = Tick Time.Posix
    | SetTimeZone Time.Zone



-- init


init : () -> ( Model, Cmd Msg )
init _ =
    let
        events =
            [ Event "first" "http://google.com" 8 30 30
            , Event "third" "http://google.com" 9 30 30
            , Event "last" "http://google.com" 15 7 1
            , Event "second" "http://google.com" 9 0 30
            ]
    in
    ( { time = Time.millisToPosix 0
      , zone = Time.utc
      , schedule = events
      , currentEvent = Nothing
      }
    , Task.perform SetTimeZone Time.here
    )



-- update


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Tick time ->
            ( updateCurrentEvent { model | time = time }, Cmd.none )

        SetTimeZone zone ->
            ( updateCurrentEvent { model | zone = zone }, Cmd.none )


updateCurrentEvent : Model -> Model
updateCurrentEvent model =
    let
        currentTime =
            Time.posixToMillis model.time

        happeningNow event =
            currentTime
                > startTimeInMillis model event
                && currentTime
                < endTimeInMillis model event

        currentEvent =
            List.head (List.filter happeningNow model.schedule)
    in
    { model | currentEvent = currentEvent }



-- view


view : Model -> Document msg
view model =
    let
        sortedEvents =
            List.sortBy (startTimeInMillis model) model.schedule
    in
    { title = "Class Time"
    , body =
        [ h2 [] [ text "Today's schedule" ]
        , p [] [ strong [] [ text "Current Time: " ], text (humanTime model.zone model.time) ]
        , p [] [ strong [] [ text "Current Event: " ], eventDetails model.currentEvent ]
        , div [] [ ul [] (List.map (eventItem model) sortedEvents) ]
        ]
    }


eventDetails : Maybe Event -> Html msg
eventDetails event =
    case event of
        Just e ->
            div []
                [ a [ href e.url ] [ text e.title ]
                ]

        Nothing ->
            div []
                [ p [] [ text "Free Time" ] ]


eventItem : Model -> Event -> Html msg
eventItem model event =
    let
        start =
            startTime model event

        end =
            endTime model event
    in
    li []
        [ a [ href event.url ] [ text event.title ]
        , p [] [ strong [] [ text "Start: " ], text (humanTime model.zone start) ]
        , p [] [ strong [] [ text "End: " ], text (humanTime model.zone end) ]
        ]


humanTime : Time.Zone -> Time.Posix -> String
humanTime zone time =
    let
        ampm =
            if Time.toHour zone time - 12 > 0 then
                "pm"

            else
                "am"

        hour =
            time
                |> Time.toHour zone
                |> modBy 12
                |> String.fromInt

        minute =
            time
                |> Time.toMinute zone
                |> String.fromInt
                |> String.padLeft 2 '0'

        second =
            time
                |> Time.toSecond zone
                |> String.fromInt
                |> String.padLeft 2 '0'
    in
    hour ++ ":" ++ minute ++ ":" ++ second ++ " " ++ ampm



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 200 Tick
