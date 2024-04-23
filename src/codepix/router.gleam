import codepix/context.{type Context}
import codepix/entities/transaction.{type Transaction}
import codepix/middlewares
import codepix/usecases/transaction_usecases.{
  create_transaction, find_transaction_by_id,
}
import gleam/http.{Get, Post}
import gleam/json
import gleam/result.{try}
import wisp.{type Request, type Response}

pub fn handler(req: Request, ctx: Context) -> Response {
  use <- middlewares.default(req)

  case wisp.path_segments(req) {
    ["transactions"] -> {
      case req.method {
        Post -> register_transaction(req, ctx)
        Get -> list_transactions(req, ctx)
        _ -> wisp.method_not_allowed([Post])
      }
    }
    ["transactions", id] -> find_transaction(req, ctx, id)
    _ -> wisp.not_found()
  }
}

fn find_transaction(req: Request, ctx: Context, id: String) -> Response {
  use <- wisp.require_method(req, Get)

  id
  |> find_transaction_by_id(ctx)
  |> result.map(transaction_to_response(_, 200))
  |> result.replace_error(wisp.not_found())
  |> result.unwrap_both
}

fn register_transaction(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)

  let transaction_result = {
    let decode_json =
      json
      |> transaction.create_transaction_payload_from_json
      |> result.replace_error(wisp.bad_request())

    use create_transaction_payload <- try(decode_json)

    create_transaction(create_transaction_payload, ctx)
    |> result.replace_error(wisp.internal_server_error())
    |> result.map(transaction_to_response(_, 201))
  }

  result.unwrap_both(transaction_result)
}

fn list_transactions(_req: Request, _ctx: Context) -> Response {
  wisp.ok()
}

fn transaction_to_response(t: Transaction, status: Int) -> Response {
  t
  |> transaction.to_json
  |> json.to_string_builder
  |> wisp.json_response(status)
}
