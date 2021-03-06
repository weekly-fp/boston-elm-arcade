module Games.Snake.View exposing (drawSquare, gameCoordToViewCoord, gamePointToViewPoint, grid, snakeSegmentSize, view)

import Collage exposing (..)
import Collage.Layout exposing (..)
import Collage.Render exposing (svg)
import Collage.Text exposing (..)
import Color
import Games.Snake.Board as Board exposing (Point)
import Games.Snake.Model as Model exposing (Model)
import Games.Snake.Snek as Snek
import Html exposing (Html)
import Html.Attributes as Hattr


snakeSegmentSize : Float
snakeSegmentSize =
    20


gamePointToViewPoint : Point -> ( Float, Float )
gamePointToViewPoint ( x, y ) =
    ( gameCoordToViewCoord x, gameCoordToViewCoord y )


gameCoordToViewCoord : Int -> Float
gameCoordToViewCoord val =
    toFloat val * snakeSegmentSize


grid : Collage msg
grid =
    let
        lineStyle =
            solid thin (uniform <| Color.rgb 40 40 40)

        lines : Int -> Int -> Collage msg
        lines size length =
            List.range (-size // 2) (size // 2)
                |> List.map
                    (\index ->
                        let
                            t =
                                toFloat index * snakeSegmentSize
                        in
                        shiftY t <|
                            traced lineStyle <|
                                Collage.line <|
                                    toFloat length
                                        * snakeSegmentSize
                    )
                |> group
    in
    group
        [ lines Board.height Board.width
        , lines Board.width Board.height |> rotate (Basics.pi / 2)
        ]


view : Model -> Html msg
view model =
    let
        boardRect : Collage msg
        boardRect =
            rectangle
                (gameCoordToViewCoord Board.width - 20 / 2)
                (gameCoordToViewCoord Board.height - 20 / 2)
                |> outlined (solid 2 (uniform Color.green))

        snek : Collage msg
        snek =
            group
                (drawSquare Color.blue model.snek.head.location
                    :: List.map (drawSquare Color.green << .location)
                        model.snek.rest
                )

        babby : Collage msg
        babby =
            drawSquare Color.yellow model.babbyPosition

        pausedTxt : Collage msg
        pausedTxt =
            fromString "PAUSED"
                |> size huge
                |> color Color.yellow
                |> rendered

        dedText : Collage msg
        dedText =
            fromString "DED"
                |> size (huge * 4)
                |> color Color.red
                |> rendered

        maybeFullscreenText : List (Collage msg)
        maybeFullscreenText =
            if model.fail then
                [ dedText ]

            else if model.paused then
                [ pausedTxt ]

            else
                []
    in
    Html.div
        [ Hattr.style "background-color" "rgb(20,20,20)"
        , Hattr.style "width" "100%"
        , Hattr.style "height" "100vh"
        , Hattr.style "display" "flex"
        , Hattr.style "flex-direction" "column"
        , Hattr.style "align-items" "center"
        , Hattr.style "justify-content" "center"
        ]
        [ Html.div
            [ Hattr.style "font-size" "40px"
            , Hattr.style "color" "white"
            ]
            [ Html.text "SNEK" ]
        , svg <|
            group <|
                (maybeFullscreenText ++ [ babby, snek, boardRect, grid ])
        , scoreView model.score
        ]


scoreView : Int -> Html msg
scoreView score =
    Html.div
        [ Hattr.style "color" "white"
        , Hattr.style "font-size" "20px"
        ]
        [ Html.text <| "Babbies Eeten: " ++ String.fromInt score ]


drawSquare : Color.Color -> Point -> Collage msg
drawSquare color point =
    square snakeSegmentSize
        |> styled ( uniform color, solid 2 <| uniform Color.black )
        |> shift (gamePointToViewPoint point)
