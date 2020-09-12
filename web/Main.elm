module Main exposing (..)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (href)
import Http
import Json.Decode exposing (Decoder, field, int, list, map5, string)
import TW as T
import Task exposing (Task)
import Time


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Msg


type Msg
    = Tick Time.Posix
    | SetTimeZone Time.Zone
    | GotSchedule (Result Http.Error (List Event))



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


fetchSchedule : Cmd Msg
fetchSchedule =
    Http.get
        { url = "https://api.mooneyclassschedule.com/schedule"
        , expect = Http.expectJson GotSchedule scheduleDecoder
        }


scheduleDecoder : Decoder (List Event)
scheduleDecoder =
    list
        (map5 Event
            (field "title" string)
            (field "url" string)
            (field "startHour" int)
            (field "startMinute" int)
            (field "durationInMinutes" int)
        )



-- Time helpers


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



-- init


init : () -> ( Model, Cmd Msg )
init _ =
    ( { time = Time.millisToPosix 0
      , zone = Time.utc
      , schedule = []
      , currentEvent = Nothing
      }
    , Cmd.batch [ fetchSchedule, Task.perform SetTimeZone Time.here ]
    )



-- update


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Tick time ->
            ( updateCurrentEvent { model | time = time }, Cmd.none )

        SetTimeZone zone ->
            ( updateCurrentEvent { model | zone = zone }, Cmd.none )

        GotSchedule result ->
            case result of
                Ok schedule ->
                    ( { model | schedule = schedule }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )


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
        [ div [ T.bg_gray_100, T.h_screen ]
            [ div [ T.container, T.mx_auto ]
                [ h2 [ T.text_center, T.font_bold ] [ text "Today's schedule" ]
                , div
                    [ T.w_40
                    , T.mx_auto
                    , T.my_40
                    , T.rounded
                    , T.shadow_lg
                    , T.text_white
                    , T.bg_reyn_purple
                    , T.p_5
                    , T.cursor_pointer
                    , T.hover__bg_reyn_gold
                    , T.hover__text_black
                    ]
                    [ p [ T.text_center ] [ text (humanTime model.zone model.time) ]
                    , p [ T.text_center ] [ strong [] [ text "Current Event: " ], eventDetails model.currentEvent ]
                    ]
                , ul [ T.justify_around, T.flex ] (List.map (eventItem model) sortedEvents)
                ]
            ]
        ]
    }


eventDetails : Maybe Event -> Html msg
eventDetails event =
    case event of
        Just e ->
            div []
                [ p [ href e.url ] [ text e.title ]
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
    li [ T.p_5 ]
        [ strong [] [ text event.title ]
        , p [] [ text (humanTime model.zone start ++ " - " ++ humanTime model.zone end) ]
        ]


humanTime : Time.Zone -> Time.Posix -> String
humanTime zone time =
    let
        ampm =
            if Time.toHour zone time - 12 >= 0 then
                "pm"

            else
                "am"

        hour =
            time
                |> Time.toHour zone
                |> modBy 12
                |> (\hr ->
                        if hr == 0 then
                            12

                        else
                            hr
                   )
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
    Time.every 1000 Tick
