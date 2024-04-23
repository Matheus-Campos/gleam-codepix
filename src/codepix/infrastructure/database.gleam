import codepix/config.{type AppConfig}
import gleam/option.{Some}
import gleam/pgo.{type Config, type Connection, Config, default_config}

pub fn with_connection(app_config: AppConfig, cb: fn(Connection) -> a) -> a {
  app_config
  |> load_config
  |> pgo.connect
  |> cb
}

fn load_config(config: AppConfig) -> Config {
  Config(
    ..default_config(),
    database: config.database_name,
    password: Some(config.database_password),
  )
}
