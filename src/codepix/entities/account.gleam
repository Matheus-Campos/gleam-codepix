import birl.{type Time}
import ids/uuid

pub type Account {
  Account(
    id: String,
    owner_name: String,
    bank_id: String,
    number: String,
    created_at: Time,
    updated_at: Time,
  )
}

pub type ValidationError

pub fn new(
  owner_name: String,
  bank_id: String,
  number: String,
) -> Result(Account, ValidationError) {
  let assert Ok(id) = uuid.generate_v4()

  Account(
    id: id,
    owner_name: owner_name,
    bank_id: bank_id,
    number: number,
    created_at: birl.now(),
    updated_at: birl.now(),
  )
  |> is_valid
}

pub fn is_valid(account: Account) -> Result(Account, ValidationError) {
  Ok(account)
}
