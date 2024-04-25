import birl.{type Time}
import codepix/helpers/database_helpers.{timestamp, timestamp_to_time}
import codepix/helpers/uuid_helpers
import gleam/dynamic.{
  type DecodeError, type DecodeErrors, type Decoder, type Dynamic, DecodeError,
  bit_array, element, field, float, optional, optional_field, string,
}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}
import gleam/result.{try}
import gleam/string

pub type Transaction {
  Transaction(
    id: String,
    account_from_id: String,
    account_to_id: String,
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

const transaction_statuses = ["pending", "confirmed", "complete", "error"]

pub type ValidationError {
  InvalidField(field: String, value: String, reason: String)
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

pub fn get_status_string(status: TransactionStatus) -> String {
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
  use account_to_id <- try(decode_element(row, 2, bit_array))
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
    account_to_id: uuid_helpers.to_string(account_to_id),
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
    #("accountFromId", json.string(transaction.account_from_id)),
    #("accountToId", json.string(transaction.account_to_id)),
    #("amount", json.float(transaction.amount)),
    #("pixKeyToId", json.string(transaction.pix_key_to_id)),
    #("status", json.string(transaction.status)),
    #("description", json.nullable(transaction.description, json.string)),
    #(
      "cancelDescription",
      json.nullable(transaction.cancel_description, json.string),
    ),
    #("createdAt", json.string(birl.to_iso8601(transaction.created_at))),
    #("updatedAt", json.string(birl.to_iso8601(transaction.updated_at))),
  ])
}

pub fn from_dynamic_json(json: Dynamic) -> Result(Transaction, DecodeErrors) {
  use id <- try(decode_field(json, "id", string))
  use account_from_id <- try(decode_field(json, "accountFromId", string))
  use account_to_id <- try(decode_field(json, "accountToId", string))
  use amount <- try(decode_field(json, "amount", float))
  use pix_key_to_id <- try(decode_field(json, "pixKeyToId", string))
  use status <- try(decode_field(json, "status", string))
  use description <- try(decode_optional_field(json, "description", string))
  use cancel_description <- try(decode_optional_field(
    json,
    "cancelDescription",
    string,
  ))
  use created_at_str <- try(decode_field(json, "createdAt", string))
  use updated_at_str <- try(decode_field(json, "updatedAt", string))

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
    field("accountFromId", string),
    field("amount", float),
    field("pixKey", string),
    optional_field("description", string),
  )(json)
}
