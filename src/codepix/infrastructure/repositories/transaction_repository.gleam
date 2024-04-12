import gleam/dynamic
import gleam/result.{try}
import gleam/pgo.{float, nullable, text}
import codepix/entities/transaction.{type Transaction}

pub type CreateTransactionError {
  DatabaseInsertError
  InvalidRow(error: dynamic.DecodeError)
}

pub fn create(
  transaction: Transaction,
  conn: pgo.Connection,
) -> Result(Transaction, CreateTransactionError) {
  let sql =
    "INSERT INTO transactions (account_from_id, amount, pix_key_to_id, status, description) VALUES ($1, $2, $3, $4, $5) RETURNING *;"

  let insert_transaction =
    sql
    |> pgo.execute(
      conn,
      [
        text(transaction.account_from_id),
        float(transaction.amount),
        text(transaction.pix_key_to_id),
        text(transaction.status),
        nullable(text, transaction.description),
      ],
      dynamic.dynamic,
    )
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
