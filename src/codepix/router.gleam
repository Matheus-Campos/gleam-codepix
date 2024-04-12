import wisp.{type Request, type Response}
import gleam/json
import gleam/http.{Post}
import codepix/context.{type Context}
import codepix/infrastructure/repositories/transaction_repository
import codepix/middlewares
import codepix/entities/transaction

pub fn handler(req: Request, ctx: Context) -> Response {
  use <- middlewares.default(req)

  case wisp.path_segments(req) {
    ["transactions"] -> {
      case req.method {
        Post -> register_transaction(req, ctx)
        _ -> wisp.method_not_allowed([Post])
      }
    }
    ["transactions", id] -> find_transaction(id, ctx)
    _ -> wisp.not_found()
  }
}

fn find_transaction(id: String, ctx: Context) -> Response {
  case transaction_repository.find(id, ctx.db) {
    Error(_) -> wisp.not_found()
    Ok(transaction) -> {
      transaction
      |> transaction.to_json
      |> json.to_string_builder
      |> wisp.json_response(200)
    }
  }
}

fn register_transaction(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)

  transaction_repository.create(json, ctx.db)
}
