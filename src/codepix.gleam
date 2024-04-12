import wisp
import mist
import gleam/erlang/process
import codepix/infrastructure/database
import codepix/context.{Context}
import codepix/router

pub fn main() {
  use conn <- database.with_connection()
  let context = Context(db: conn)

  wisp.configure_logger()
  let secret_key_base = wisp.random_string(256)

  router.handler(_, context)
  |> wisp.mist_handler(secret_key_base)
  |> mist.new
  |> mist.port(8000)
  |> mist.start_http

  process.sleep_forever()
}
