import codepix/entities/account.{type Account, get_account_return_type}
import gleam/pgo
import gleam/result.{try}

pub type FindAccountError {
  AccountNotFound
}

pub fn find_account_by_pix_key(
  conn: pgo.Connection,
  pix_key: String,
) -> Result(Account, FindAccountError) {
  let sql =
    "SELECT acc.* FROM \"pixKeys\" AS p JOIN accounts AS acc ON acc.id = p.\"accountId\" WHERE p.key = $1;"

  let get_account =
    sql
    |> pgo.execute(conn, [pgo.text(pix_key)], get_account_return_type())
    |> result.replace_error(AccountNotFound)

  use returned <- try(get_account)

  case returned.rows {
    [] -> Error(AccountNotFound)
    [row, ..] ->
      account.from_dynamic_tuple(row)
      |> result.replace_error(AccountNotFound)
  }
}
