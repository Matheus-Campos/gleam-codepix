import codepix/context.{type Context}
import codepix/middlewares
import codepix/routes/transaction_routes
import wisp.{type Request, type Response}

pub fn handler(req: Request, ctx: Context) -> Response {
  use <- middlewares.default(req)

  case wisp.path_segments(req) {
    ["transactions", ..path_segments] ->
      transaction_routes.handle_request(req, ctx, path_segments)
    _ -> wisp.not_found()
  }
}
