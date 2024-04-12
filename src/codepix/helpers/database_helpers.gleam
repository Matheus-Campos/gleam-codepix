import gleam/dynamic.{type Decoder, float, int, tuple2, tuple3}

pub type Timestamp =
  #(#(Int, Int, Int), #(Int, Int, Float))

pub fn timestamp() -> Decoder(Timestamp) {
  tuple2(tuple3(int, int, int), tuple3(int, int, float))
}
