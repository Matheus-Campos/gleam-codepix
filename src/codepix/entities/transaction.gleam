import birl.{type Time}
import codepix/helpers/database_helpers.{type Timestamp, timestamp}
import codepix/helpers/uuid_helpers
import gleam/dynamic.{
  type DecodeError, type DecodeErrors, type Decoder, type Dynamic, DecodeError,
  bit_array, element, field, float, optional, optional_field, string,
}
import gleam/float
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None}
import gleam/result.{try}
import gleam/string
import ids/uuid

pub type Transaction {
  Transaction(
    id: String,
    account_from_id: String,
    account_to_id: Option(String),
    amount: Float,
    pix_key_to_id: String,
    status: String,
    description: Option(String),
    cancel_description: Option(String),
    created_at: Time,
    updated_at: Time,
  )
}

pub type CreateTransactionPayload {
  CreateTransactionPayload(
    account_from_id: String,
    amount: Float,
    pix_key: String,
    description: Option(String),
  )
}

pub type TransactionStatus {
  TransactionPending
  TransactionCompleted
  TransactionConfirmed
  TransactionError
}

const transaction_statuses = ["pending", "confirmed", "status", "error"]

pub type ValidationError {
  InvalidField(field: String, value: String, reason: String)
}

pub fn new(
  from account_from_id: String,
  amount amount: Float,
  to_key pix_key_to_id: String,
  description description: Option(String),
) -> Result(Transaction, ValidationError) {
  let assert Ok(id) = uuid.generate_v4()

  Transaction(
    id: id,
    account_from_id: account_from_id,
    account_to_id: None,
    amount: amount,
    pix_key_to_id: pix_key_to_id,
    status: get_status_string(TransactionPending),
    description: description,
    cancel_description: None,
    created_at: birl.now(),
    updated_at: birl.now(),
  )
  |> is_valid
}

pub fn is_valid(
  transaction: Transaction,
) -> Result(Transaction, ValidationError) {
  case list.contains(transaction_statuses, transaction.status) {
    False ->
      Error(InvalidField(
        field: "status",
        value: transaction.status,
        reason: "is not one of the following: "
          <> string.join(transaction_statuses, with: ", "),
      ))
    True -> Ok(transaction)
  }
}

fn get_status_string(status: TransactionStatus) -> String {
  case status {
    TransactionPending -> "pending"
    TransactionCompleted -> "completed"
    TransactionConfirmed -> "confirmed"
    TransactionError -> "error"
  }
}

pub fn from_row(row: Dynamic) -> Result(Transaction, DecodeError) {
  use id_bytes <- try(decode_element(row, 0, bit_array))
  use account_from_id <- try(decode_element(row, 1, bit_array))
  use account_to_id <- try(decode_element(row, 2, optional(bit_array)))
  use amount <- try(decode_element(row, 3, float))
  use pix_key_to_id <- try(decode_element(row, 4, bit_array))
  use status <- try(decode_element(row, 5, string))
  use description <- try(decode_element(row, 6, optional(string)))
  use cancel_description <- try(decode_element(row, 7, optional(string)))
  use created_at_tuple <- try(decode_element(row, 8, timestamp()))
  use updated_at_tuple <- try(decode_element(row, 9, timestamp()))

  let parse_created_at =
    timestamp_to_time(created_at_tuple)
    |> result.replace_error(
      DecodeError(expected: "datetime", found: "invalid datetime", path: [
        "created_at",
      ]),
    )

  let parse_updated_at =
    timestamp_to_time(updated_at_tuple)
    |> result.replace_error(
      DecodeError(expected: "datetime", found: "invalid datetime", path: [
        "updated_at",
      ]),
    )

  use created_at <- try(parse_created_at)
  use updated_at <- try(parse_updated_at)

  Transaction(
    id: uuid_helpers.to_string(id_bytes),
    account_from_id: uuid_helpers.to_string(account_from_id),
    account_to_id: option.map(account_to_id, uuid_helpers.to_string),
    amount: amount,
    pix_key_to_id: uuid_helpers.to_string(pix_key_to_id),
    status: status,
    description: description,
    cancel_description: cancel_description,
    created_at: created_at,
    updated_at: updated_at,
  )
  |> is_valid
  |> result.map_error(fn(error) {
    DecodeError(expected: error.reason, found: error.value, path: [error.field])
  })
}

fn timestamp_to_time(stamp: Timestamp) -> Result(Time, Nil) {
  let date = stamp.0
  let time = stamp.1

  let date_str =
    [date.0, date.1, date.2]
    |> list.map(int.to_string)
    |> string.join(with: "-")

  let time_str =
    [int.to_string(time.0), int.to_string(time.1), float.to_string(time.2)]
    |> string.join(with: ":")

  let formatted_timestamp = date_str <> "T" <> time_str <> "Z"

  birl.parse(formatted_timestamp)
}

fn decode_element(
  row: Dynamic,
  index: Int,
  decoder: Decoder(a),
) -> Result(a, DecodeError) {
  element(index, decoder)(row)
  |> result.map_error(fn(errors) {
    let assert [error] = errors
    error
  })
}

pub fn to_json(transaction: Transaction) -> Json {
  json.object([
    #("id", json.string(transaction.id)),
    #("account_from_id", json.string(transaction.account_from_id)),
    #("account_to_id", json.nullable(transaction.account_to_id, json.string)),
    #("amount", json.float(transaction.amount)),
    #("pix_key_to_id", json.string(transaction.pix_key_to_id)),
    #("status", json.string(transaction.status)),
    #("description", json.nullable(transaction.description, json.string)),
    #(
      "cancel_description",
      json.nullable(transaction.cancel_description, json.string),
    ),
    #("created_at", json.string(birl.to_iso8601(transaction.created_at))),
    #("updated_at", json.string(birl.to_iso8601(transaction.updated_at))),
  ])
}

pub fn from_dynamic_json(json: Dynamic) -> Result(Transaction, DecodeErrors) {
  use id <- try(decode_field(json, "id", string))
  use account_from_id <- try(decode_field(json, "account_from_id", string))
  use account_to_id <- try(decode_optional_field(json, "account_to_id", string))
  use amount <- try(decode_field(json, "amount", float))
  use pix_key_to_id <- try(decode_field(json, "pix_key_to_id", string))
  use status <- try(decode_field(json, "status", string))
  use description <- try(decode_optional_field(json, "description", string))
  use cancel_description <- try(decode_optional_field(
    json,
    "cancel_description",
    string,
  ))
  use created_at_str <- try(decode_field(json, "created_at", string))
  use updated_at_str <- try(decode_field(json, "updated_at", string))

  use created_at <- try(string_to_time(created_at_str, "created_at"))
  use updated_at <- try(string_to_time(updated_at_str, "updated_at"))

  Ok(Transaction(
    id: id,
    account_from_id: account_from_id,
    account_to_id: account_to_id,
    amount: amount,
    pix_key_to_id: pix_key_to_id,
    status: status,
    description: description,
    cancel_description: cancel_description,
    created_at: created_at,
    updated_at: updated_at,
  ))
}

fn decode_field(
  json: Dynamic,
  field_name: String,
  decoder: Decoder(a),
) -> Result(a, DecodeErrors) {
  json
  |> field(named: field_name, of: decoder)
}

fn decode_optional_field(
  json: Dynamic,
  field_name: String,
  decoder: Decoder(a),
) -> Result(Option(a), DecodeErrors) {
  json
  |> optional_field(named: field_name, of: decoder)
}

fn string_to_time(t: String, field_name: String) -> Result(Time, DecodeErrors) {
  t
  |> birl.parse
  |> result.replace_error([
    DecodeError(found: "Invalid timestamp", expected: "Timestamp", path: [
      field_name,
    ]),
  ])
}

pub fn create_transaction_payload_from_json(
  json: Dynamic,
) -> Result(CreateTransactionPayload, DecodeErrors) {
  dynamic.decode4(
    CreateTransactionPayload,
    field("account_from_id", string),
    field("amount", float),
    field("pix_key", string),
    optional_field("description", string),
  )(json)
}
