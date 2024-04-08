import gleam/option.{None}
import gleam/result.{try}
import codepix/entities/transaction.{type Transaction}
import codepix/entities/account.{type Account}
import codepix/context.{type Context}
import codepix/infrastructure/repositories/transaction_repository

pub type RegistrationError {
  ValidationError
  QueryError
}

pub fn register_transaction(
  account: Account,
  amount: Float,
  pix_key: String,
  context: Context,
) -> Result(Transaction, RegistrationError) {
  let create_transaction =
    transaction.new(
      from: account.id,
      amount: amount,
      to_key: pix_key,
      description: None,
    )
    |> result.replace_error(ValidationError)

  use transaction <- try(create_transaction)

  transaction
  |> transaction_repository.create(context.db)
  |> result.replace_error(QueryError)
}

pub type ConfirmationError

pub fn confirm_transaction() {
  todo
}