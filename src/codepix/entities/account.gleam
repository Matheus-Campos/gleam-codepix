import birl.{type Time}
import codepix/helpers/database_helpers.{
  type Timestamp, timestamp, timestamp_to_time,
}
import codepix/helpers/uuid_helpers
import gleam/dynamic.{type Decoder}
import gleam/result.{try}
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

pub type AccountTuple =
  #(BitArray, String, String, BitArray, Timestamp, Timestamp)

pub fn get_account_return_type() -> Decoder(AccountTuple) {
  dynamic.tuple6(
    dynamic.bit_array,
    dynamic.string,
    dynamic.string,
    dynamic.bit_array,
    timestamp(),
    timestamp(),
  )
}

pub fn is_valid(account: Account) -> Result(Account, ValidationError) {
  Ok(account)
}

pub fn from_dynamic_tuple(account_tuple: AccountTuple) -> Result(Account, Nil) {
  use created_at <- try(timestamp_to_time(account_tuple.4))
  use updated_at <- try(timestamp_to_time(account_tuple.5))

  Ok(Account(
    id: uuid_helpers.to_string(account_tuple.0),
    owner_name: account_tuple.1,
    number: account_tuple.2,
    bank_id: uuid_helpers.to_string(account_tuple.3),
    created_at: created_at,
    updated_at: updated_at,
  ))
}
