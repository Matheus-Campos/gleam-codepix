import codepix/context.{type Context}
import codepix/entities/transaction.{
  type CreateTransactionPayload, type Transaction,
}
import codepix/infrastructure/repositories/account_repository
import codepix/infrastructure/repositories/pix_key_repository
import codepix/infrastructure/repositories/transaction_repository
import gleam/result.{try}
import wisp

pub type RegistrationError {
  QueryError
  PixKeyNotFound
  AccountNotFound
}

pub fn create_transaction(
  create_transaction_payload: CreateTransactionPayload,
  context: Context,
) -> Result(Transaction, RegistrationError) {
  wisp.log_info("Executing create transaction use case")

  let find_account =
    context.db
    |> account_repository.find_account_by_pix_key(
      create_transaction_payload.pix_key,
    )
    |> result.replace_error(AccountNotFound)

  let find_pix_key =
    context.db
    |> pix_key_repository.find_by_key(create_transaction_payload.pix_key)
    |> result.replace_error(PixKeyNotFound)

  use account_to <- try(find_account)
  use pix_key <- try(find_pix_key)

  context.db
  |> transaction_repository.create(
    create_transaction_payload,
    account_to.id,
    pix_key.id,
  )
  |> result.replace_error(QueryError)
}

pub type UpdateTransactionError {
  TransactionNotFound
}

pub fn confirm_transaction(
  context: Context,
  id: String,
) -> Result(Transaction, UpdateTransactionError) {
  context.db
  |> transaction_repository.confirm(id)
  |> result.replace_error(TransactionNotFound)
}

pub fn complete_transaction(
  context: Context,
  id: String,
) -> Result(Transaction, UpdateTransactionError) {
  context.db
  |> transaction_repository.complete(id)
  |> result.replace_error(TransactionNotFound)
}
