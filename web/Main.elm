module Main exposing (..)

import Browser exposing (Document)
import Html exposing (..)


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = \cmd -> Sub.none
        }



-- init


init : () -> ( String, Cmd msg )
init _ =
    ( "Hello World", Cmd.none )



-- update


update : msg -> String -> ( String, Cmd msg )
update msg model =
    ( model, Cmd.none )


view : String -> Document msg
view model =
    { title = "Class Time"
    , body = [ h2 [] [ text model ] ]
    }
