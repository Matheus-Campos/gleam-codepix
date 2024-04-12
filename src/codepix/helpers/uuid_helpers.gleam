import gleam/int

pub fn to_string(ints: BitArray) {
  parse_to_string(ints, 0, "", "-")
}

fn parse_to_string(
  ints: BitArray,
  position: Int,
  acc: String,
  separator: String,
) -> String {
  case position {
    8 | 13 | 18 | 23 ->
      parse_to_string(ints, position + 1, acc <> separator, separator)
    _ ->
      case ints {
        <<i:size(4), rest:bits>> -> {
          parse_to_string(
            rest,
            position + 1,
            acc <> int.to_base16(i),
            separator,
          )
        }
        _ -> acc
      }
  }
}
