import codepix/context.{type Context}
import codepix/entities/transaction.{
  type CreateTransactionPayload, type Transaction,
}
import codepix/infrastructure/repositories/transaction_repository
import gleam/result

pub type RegistrationError {
  ValidationError
  QueryError
}

pub type FindError {
  TransactionNotFound
}

pub fn create_transaction(
  create_transaction_payload: CreateTransactionPayload,
  context: Context,
) -> Result(Transaction, RegistrationError) {
  create_transaction_payload
  |> transaction_repository.create(context.db)
  |> result.replace_error(QueryError)
}

pub fn find_transaction_by_id(
  id: String,
  ctx: Context,
) -> Result(Transaction, FindError) {
  id
  |> transaction_repository.find(ctx.db)
  |> result.replace_error(TransactionNotFound)
}
