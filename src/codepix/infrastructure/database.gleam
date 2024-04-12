import gleam/pgo.{type Connection, Config, default_config}
import gleam/option.{Some}

pub fn with_connection(cb: fn(Connection) -> a) -> a {
  pgo.connect(
    Config(..default_config(), database: "codepix", password: Some("root123")),
  )
  |> cb
}
