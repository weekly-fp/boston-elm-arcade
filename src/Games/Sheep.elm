module Games.Sheep exposing (Model, Msg(..), Sheep, init, subscriptions, update, view)

import Browser.Events
import Collage exposing (Collage, filled, rectangle, shift, uniform)
import Collage.Render as Render
import Color exposing (Color, rgb)
import Html exposing (Html)
import Json.Decode


type alias Model =
    { doggo : Doggo
    , sheep : List Sheep
    , lastmsg : Maybe Msg
    }


type Msg
    = Tick Float
    | Keydown String
    | Keyup String


type alias Doggo =
    { pos : Pos
    , vel : Vel
    }


type alias Sheep =
    { pos : Pos
    , vel : Vel
    }


type alias Pos =
    { x : Float
    , y : Float
    }


type alias Vel =
    { x : Float
    , y : Float
    }


init : Model
init =
    { lastmsg = Nothing
    , doggo =
        { pos = { x = 0, y = 0 }
        , vel = { x = 0, y = 0 }
        }
    , sheep = []
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( { model | lastmsg = Just msg }, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div
        []
        (List.concat
            [ [ Html.text (Debug.toString model) ]
            , List.map (viewSheep >> Render.svg) model.sheep
            ]
        )


viewSheep : Sheep -> Collage Msg
viewSheep sheep =
    rectangle
        16
        16
        |> filled (uniform (rgb 220 220 220))
        |> shift ( sheep.pos.x, sheep.pos.y )


subscriptions : Model -> Sub Msg
subscriptions _ =
    let
        keyDecoder : Json.Decode.Decoder String
        keyDecoder =
            Json.Decode.field "key" Json.Decode.string
    in
    Sub.batch
        [ Browser.Events.onAnimationFrameDelta Tick
        , Browser.Events.onKeyDown (Json.Decode.map Keydown keyDecoder)
        , Browser.Events.onKeyUp (Json.Decode.map Keyup keyDecoder)
        ]