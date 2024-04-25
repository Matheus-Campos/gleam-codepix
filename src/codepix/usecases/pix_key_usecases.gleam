import codepix/entities/pix_key.{
  type CreatePixKeyPayload, type PixKey, pix_key_tuple_decoder,
}
import gleam/pgo.{text}
import gleam/result.{try}

pub fn create_pix_key(
  conn: pgo.Connection,
  create_pix_key_payload: CreatePixKeyPayload,
) -> Result(PixKey, Nil) {
  let sql =
    "INSERT INTO \"pixKeys\" (kind, key, \"accountId\") VALUES ($1, $2, $3) RETURNING *"

  let insert_pix_key =
    sql
    |> pgo.execute(
      conn,
      [
        text(create_pix_key_payload.kind),
        text(create_pix_key_payload.key),
        text(create_pix_key_payload.account_id),
      ],
      pix_key_tuple_decoder,
    )
    |> result.nil_error

  use returned <- try(insert_pix_key)
  let assert [row] = returned.rows

  pix_key.from_tuple(row)
}
