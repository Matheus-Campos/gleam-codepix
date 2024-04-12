import wisp.{type Request, type Response}

pub fn default(req: Request, handle_request: fn() -> Response) -> Response {
  use <- wisp.log_request(req)

  use _ <- wisp.handle_head(req)

  use <- wisp.rescue_crashes

  handle_request()
}
