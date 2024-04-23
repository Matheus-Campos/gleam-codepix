import dot_env
import dot_env/env
import gleam/result.{nil_error, try}

pub type AppConfig {
  AppConfig(database_name: String, database_password: String)
}

pub fn load() -> Result(AppConfig, Nil) {
  dot_env.load()

  use db_name <- try(nil_error(env.get("DATABASE_NAME")))
  use db_password <- try(nil_error(env.get("DATABASE_PASSWORD")))

  Ok(AppConfig(database_name: db_name, database_password: db_password))
}
