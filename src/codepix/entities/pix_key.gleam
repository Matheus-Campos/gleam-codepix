import gleam/result.{try}
import birl.{type Time}
import ids/uuid

pub type PixKey {
  PixKey(
    id: String,
    kind: String,
    key: String,
    account_id: String,
    status: String,
    created_at: Time,
    updated_at: Time,
  )
}

pub type PixKeyKind {
  EmailKind
  CpfKind
}

pub type ValidationError {
  InvalidKind
  InvalidStatus
}

pub fn new(
  kind: PixKeyKind,
  account_id: String,
  key: String,
) -> Result(PixKey, ValidationError) {
  let kind = case kind {
    EmailKind -> "email"
    CpfKind -> "cpf"
  }

  let assert Ok(id) = uuid.generate_v4()

  PixKey(
    id: id,
    kind: kind,
    key: key,
    account_id: account_id,
    status: "active",
    created_at: birl.now(),
    updated_at: birl.now(),
  )
  |> is_valid
}

pub fn is_valid(key: PixKey) -> Result(PixKey, ValidationError) {
  use _ <- try(check_invalid_kind(key.kind))
  use _ <- try(check_invalid_status(key.status))
  Ok(key)
}

fn check_invalid_kind(kind: String) -> Result(Nil, ValidationError) {
  case kind {
    "email" | "cpf" -> Ok(Nil)
    _ -> Error(InvalidKind)
  }
}

fn check_invalid_status(status: String) -> Result(Nil, ValidationError) {
  case status {
    "active" | "inactive" -> Ok(Nil)
    _ -> Error(InvalidStatus)
  }
}
