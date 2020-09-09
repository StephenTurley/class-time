module Main exposing (..)

import Browser exposing (Document)
import Html exposing (..)
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
    ( [], Cmd.none )



-- update


update : msg -> Model -> ( Model, Cmd msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Document msg
view model =
    { title = "Class Time"
    , body = [ h2 [] [ text "hello world" ] ]
    }
