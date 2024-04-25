import codepix/context.{type Context}
import codepix/entities/pix_key.{type PixKey, create_pix_key_payload_from_json}
import codepix/usecases/pix_key_usecases.{create_pix_key}
import gleam/http.{Post}
import gleam/json
import gleam/result.{try}
import wisp.{type Request, type Response}

pub fn handle_request(
  req: Request,
  ctx: Context,
  path: List(String),
) -> Response {
  case path {
    [] -> create_key(req, ctx)
    _ -> wisp.not_found()
  }
}

fn create_key(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_json(req)

  let res = {
    let decode_json =
      create_pix_key_payload_from_json(json)
      |> result.nil_error

    use create_pix_key_payload <- try(decode_json)

    create_pix_key(ctx.db, create_pix_key_payload)
  }

  case res {
    Ok(pix_key) -> pix_key_to_response(pix_key, 201)
    Error(_) -> wisp.bad_request()
  }
}

fn pix_key_to_response(pix_key: PixKey, status: Int) -> Response {
  pix_key
  |> pix_key.to_json
  |> json.to_string_builder
  |> wisp.json_response(status)
}
