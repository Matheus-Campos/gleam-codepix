import codepix/entities/transaction.{
  type CreateTransactionPayload, type Transaction,
}
import gleam/dynamic
import gleam/io.{debug}
import gleam/pgo.{float, nullable, text}
import gleam/result.{try}

pub type CreateTransactionError {
  DatabaseInsertError
  InvalidRow(error: dynamic.DecodeError)
}

pub fn create(
  create_transaction_payload: CreateTransactionPayload,
  conn: pgo.Connection,
) -> Result(Transaction, CreateTransactionError) {
  let sql =
    "INSERT INTO transactions (\"accountFromId\", amount, \"pixKeyToId\", description) VALUES ($1, $2, $3, $4) RETURNING *;"

  let insert_transaction =
    sql
    |> pgo.execute(
      conn,
      [
        text(create_transaction_payload.account_from_id),
        float(create_transaction_payload.amount),
        text(create_transaction_payload.pix_key),
        nullable(text, create_transaction_payload.description),
      ],
      dynamic.dynamic,
    )
    |> debug
    |> result.replace_error(DatabaseInsertError)

  use returned <- try(insert_transaction)
  let assert [row] = returned.rows

  row
  |> transaction.from_row
  |> result.map_error(fn(error) { InvalidRow(error: error) })
}

pub type FindTransactionError {
  DatabaseSelectError
  TransactionNotFoundError
  DecodeErrorOnFind(error: dynamic.DecodeError)
}

pub fn find(
  transaction_id: String,
  conn: pgo.Connection,
) -> Result(Transaction, FindTransactionError) {
  let sql = "SELECT * FROM transactions WHERE id = $1;"

  let find_result =
    sql
    |> pgo.execute(conn, [text(transaction_id)], dynamic.dynamic)
    |> result.replace_error(DatabaseSelectError)

  use returned <- try(find_result)

  case returned.rows {
    [] -> Error(TransactionNotFoundError)
    [row, ..] -> {
      row
      |> transaction.from_row
      |> result.map_error(fn(error) { DecodeErrorOnFind(error: error) })
    }
  }
}
