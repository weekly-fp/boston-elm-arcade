module Key exposing (Key(..), decoder)

import Json.Decode as Decode


type Key
    = Left
    | Right
    | Up
    | Down
    | Space
    | Other String


decoder : Decode.Decoder Key
decoder =
    Decode.map fromStr (Decode.field "key" Decode.string)


fromStr : String -> Key
fromStr string =
    case string of
        "ArrowLeft" ->
            Left

        "ArrowRight" ->
            Right

        "ArrowUp" ->
            Up

        "ArrowDown" ->
            Down

        " " ->
            Space

        _ ->
            Other string
