import birl.{type Time}
import ids/uuid

pub type Bank {
  Bank(
    id: String,
    code: String,
    name: String,
    created_at: Time,
    updated_at: Time,
  )
}

pub type ValidationError

pub fn new(code: String, name: String) -> Result(Bank, ValidationError) {
  let assert Ok(id) = uuid.generate_v4()

  Bank(
    id: id,
    code: code,
    name: name,
    created_at: birl.now(),
    updated_at: birl.now(),
  )
  |> is_valid
}

pub fn is_valid(bank: Bank) -> Result(Bank, ValidationError) {
  Ok(bank)
}
