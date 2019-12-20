port module Main exposing (Model, Msg(..), Stock, init, main, stockupdate)

import Browser
import Html exposing (Html, div, text)
import Json.Decode exposing (Decoder, decodeValue, field, float, map3, string)
import Json.Encode as E


type Model
    = Waiting
    | StockInfo Stock
    | Error


type Msg
    = StockChanged E.Value


type alias Stock =
    { symbol : String
    , price : Float
    , time : String
    }


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Waiting
    , Cmd.none
    )


port stockupdate : (E.Value -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    stockupdate StockChanged


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case Debug.log "[elm]" msg of
        StockChanged value ->
            let
                stockInfo =
                    decodeValue stockInfoDecoder value
            in
            case stockInfo of
                Ok info ->
                    ( StockInfo info, Cmd.none )

                Err _ ->
                    ( Error, Cmd.none )


stockInfoDecoder : Decoder Stock
stockInfoDecoder =
    map3 Stock
        (field "symbol" string)
        (field "price" float)
        (field "time" string)


view : Model -> Html Msg
view model =
    div []
        [ case model of
            Waiting ->
                text "waiting..."

            StockInfo stock ->
                stock.symbol ++ " " ++ (String.fromFloat stock.price) ++ " at " ++ stock.time |> text

            Error ->
                text "Error"
        ]
