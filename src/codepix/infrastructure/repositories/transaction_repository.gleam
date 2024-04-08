import gleam/dynamic
import gleam/result.{try}
import gleam/pgo.{float, nullable, text}
import codepix/entities/transaction.{
  type Transaction, get_transaction_return_type,
}

pub fn create(transaction: Transaction, conn: pgo.Connection) {
  let sql =
    "INSERT INTO transactions (account_from_id, amount, pix_key_to_id, status, description) VALUES ($1, $2, $3, $4, $5);"

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
  |> result.replace(transaction)
}

pub fn find(transaction_id: String, conn: pgo.Connection) {
  let sql = ""

  let find_result =
    pgo.execute(
      sql,
      conn,
      [text(transaction_id)],
      get_transaction_return_type(),
    )
    |> result.nil_error()
  use returned <- try(find_result)

  case returned.rows {
    [] -> Error(Nil)
    [row, ..] -> row
  }
}
