import codepix/entities/transaction.{
  type CreateTransactionPayload, type Transaction,
}
import gleam/dynamic
import gleam/pgo.{float, nullable, text}
import gleam/result.{try}

pub type TransactionRepositoryError {
  DatabaseInsertError
  InvalidRow(error: dynamic.DecodeError)
  TransactionNotFound
}

pub fn create(
  conn: pgo.Connection,
  create_transaction_payload: CreateTransactionPayload,
  account_to_id: String,
  pix_key_to_id: String,
) -> Result(Transaction, TransactionRepositoryError) {
  let sql =
    "INSERT INTO transactions (\"accountFromId\", \"accountToId\", amount, \"pixKeyToId\", description) VALUES ($1, $2, $3, $4, $5) RETURNING *;"

  let insert_transaction =
    sql
    |> pgo.execute(
      conn,
      [
        text(create_transaction_payload.account_from_id),
        text(account_to_id),
        float(create_transaction_payload.amount),
        text(pix_key_to_id),
        nullable(text, create_transaction_payload.description),
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

pub fn confirm(
  conn: pgo.Connection,
  id: String,
) -> Result(Transaction, TransactionRepositoryError) {
  let sql =
    "UPDATE \"transactions\" SET \"status\" = 'confirmed' WHERE id = $1 AND \"status\" = 'pending' RETURNING *"

  let find_transaction =
    sql
    |> pgo.execute(conn, [text(id)], dynamic.dynamic)
    |> result.replace_error(TransactionNotFound)

  use returned <- try(find_transaction)
  let assert [row] = returned.rows

  row
  |> transaction.from_row
  |> result.map_error(fn(error) { InvalidRow(error: error) })
}

pub fn complete(
  conn: pgo.Connection,
  id: String,
) -> Result(Transaction, TransactionRepositoryError) {
  let sql =
    "UPDATE \"transactions\" SET \"status\" = 'complete' WHERE id = $1 AND \"status\" = 'confirmed' RETURNING *"

  let find_transaction =
    sql
    |> pgo.execute(conn, [text(id)], dynamic.dynamic)
    |> result.replace_error(TransactionNotFound)

  use returned <- try(find_transaction)
  let assert [row] = returned.rows

  row
  |> transaction.from_row
  |> result.map_error(fn(error) { InvalidRow(error: error) })
}
