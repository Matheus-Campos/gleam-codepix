import codepix/context.{type Context}
import codepix/entities/transaction.{type Transaction}
import codepix/usecases/transaction_usecases.{create_transaction}
import gleam/http.{Post}
import gleam/json
import gleam/result.{try}
import wisp.{type Request, type Response}

pub fn handle_request(
  req: Request,
  ctx: Context,
  path_segments: List(String),
) -> Response {
  case path_segments {
    [] -> register_transaction(req, ctx)
    [id, "confirm"] -> confirm_transaction(req, ctx, id)
    [id, "complete"] -> complete_transaction(req, ctx, id)
    _ -> wisp.not_found()
  }
}

pub type RegisterTransactionError {
  InvalidPayload
  TransactionCreationError
}

fn register_transaction(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_json(req)

  let transaction_result = {
    let decode_json =
      transaction.create_transaction_payload_from_json(json)
      |> result.replace_error(InvalidPayload)

    use create_transaction_payload <- try(decode_json)

    create_transaction(create_transaction_payload, ctx)
    |> result.replace_error(TransactionCreationError)
  }

  case transaction_result {
    Ok(transaction) -> transaction_to_response(transaction, 201)
    Error(_) -> wisp.unprocessable_entity()
  }
}

fn confirm_transaction(req: Request, ctx: Context, id: String) -> Response {
  use <- wisp.require_method(req, Post)

  case transaction_usecases.confirm_transaction(ctx, id) {
    Ok(transaction) -> transaction_to_response(transaction, 200)
    Error(_) -> wisp.unprocessable_entity()
  }
}

fn complete_transaction(req: Request, ctx: Context, id: String) -> Response {
  use <- wisp.require_method(req, Post)

  case transaction_usecases.complete_transaction(ctx, id) {
    Ok(transaction) -> transaction_to_response(transaction, 200)
    Error(_) -> wisp.unprocessable_entity()
  }
}

fn transaction_to_response(t: Transaction, status: Int) -> Response {
  t
  |> transaction.to_json
  |> json.to_string_builder
  |> wisp.json_response(status)
}
