import birl.{type Time}
import gleam/dynamic.{type Decoder, float, int, tuple2, tuple3}
import gleam/float
import gleam/int
import gleam/list
import gleam/string

pub type Timestamp =
  #(#(Int, Int, Int), #(Int, Int, Float))

pub fn timestamp() -> Decoder(Timestamp) {
  tuple2(tuple3(int, int, int), tuple3(int, int, float))
}

pub fn timestamp_to_time(timestamp: Timestamp) -> Result(Time, Nil) {
  let date = timestamp.0
  let time = timestamp.1

  let date_str =
    [date.0, date.1, date.2]
    |> list.map(int.to_string)
    |> string.join(with: "-")

  let time_str =
    [int.to_string(time.0), int.to_string(time.1), float.to_string(time.2)]
    |> string.join(with: ":")

  let formatted_timestamp = date_str <> "T" <> time_str <> "Z"

  birl.parse(formatted_timestamp)
}
