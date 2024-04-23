import codepix/config
import codepix/context.{Context}
import codepix/infrastructure/database
import codepix/router
import gleam/erlang/process
import gleam/io
import gleam/result.{try}
import mist
import wisp

pub fn main() {
  let load_config =
    config.load()
    |> result.map_error(fn(_) { io.println("Environment could not be loaded") })

  use app_config <- try(load_config)

  use conn <- database.with_connection(app_config)
  let context = Context(db: conn)

  wisp.configure_logger()
  let secret_key_base = wisp.random_string(256)

  let _ =
    router.handler(_, context)
    |> wisp.mist_handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  Ok(process.sleep_forever())
}
