import codepix/entities/pix_key.{type PixKey, get_pix_key_return_type}
import gleam/io.{debug}
import gleam/pgo
import gleam/result.{try}

pub type FindError {
  PixKeyNotFound
  PixKeyDecodeError
}

pub fn find_by_key(
  conn: pgo.Connection,
  key: String,
) -> Result(PixKey, FindError) {
  let sql = "SELECT * FROM \"pixKeys\" WHERE id = $1"

  let find_pix_key =
    sql
    |> pgo.execute(conn, [pgo.text(key)], get_pix_key_return_type())
    |> debug
    |> result.replace_error(PixKeyNotFound)

  use returned <- try(find_pix_key)

  case returned.rows {
    [] -> Error(PixKeyNotFound)
    [row, ..] -> {
      row
      |> pix_key.from_tuple
      |> result.replace_error(PixKeyDecodeError)
    }
  }
}
