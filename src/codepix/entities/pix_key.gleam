import birl.{type Time}
import codepix/helpers/database_helpers.{
  type Timestamp, timestamp, timestamp_to_time,
}
import codepix/helpers/uuid_helpers
import gleam/dynamic.{
  type DecodeErrors, type Decoder, type Dynamic, bit_array, element, field,
  string,
}
import gleam/json.{type Json}
import gleam/result.{try}

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

pub type ValidationError {
  InvalidKind
  InvalidStatus
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

pub type PixKeyTuple =
  #(BitArray, String, String, BitArray, String, Timestamp, Timestamp)

pub fn pix_key_tuple_decoder(dyn: Dynamic) -> Result(PixKeyTuple, DecodeErrors) {
  let decode_tuple_element = fn(position: Int, decoder: Decoder(a)) {
    decode_element(dyn, position, decoder)
  }

  use id <- try(decode_tuple_element(0, bit_array))
  use kind <- try(decode_tuple_element(1, string))
  use key <- try(decode_tuple_element(2, string))
  use account_id <- try(decode_tuple_element(3, bit_array))
  use status <- try(decode_tuple_element(4, string))
  use created_at <- try(decode_tuple_element(5, timestamp()))
  use updated_at <- try(decode_tuple_element(6, timestamp()))

  Ok(#(id, kind, key, account_id, status, created_at, updated_at))
}

fn decode_element(
  dyn: Dynamic,
  position: Int,
  decoder: Decoder(a),
) -> Result(a, DecodeErrors) {
  element(position, decoder)(dyn)
}

pub fn from_tuple(tuple: PixKeyTuple) -> Result(PixKey, Nil) {
  use created_at <- try(timestamp_to_time(tuple.5))
  use updated_at <- try(timestamp_to_time(tuple.6))

  Ok(PixKey(
    id: uuid_helpers.to_string(tuple.0),
    kind: tuple.1,
    key: tuple.2,
    account_id: uuid_helpers.to_string(tuple.3),
    status: tuple.4,
    created_at: created_at,
    updated_at: updated_at,
  ))
}

pub fn to_json(pix_key: PixKey) -> Json {
  json.object([
    #("id", json.string(pix_key.id)),
    #("kind", json.string(pix_key.kind)),
    #("key", json.string(pix_key.key)),
    #("accountId", json.string(pix_key.account_id)),
    #("status", json.string(pix_key.status)),
    #("createdAt", json.string(birl.to_iso8601(pix_key.created_at))),
    #("updatedAt", json.string(birl.to_iso8601(pix_key.updated_at))),
  ])
}

pub type CreatePixKeyPayload {
  CreatePixKeyPayload(kind: String, key: String, account_id: String)
}

pub fn create_pix_key_payload_from_json(
  json: Dynamic,
) -> Result(CreatePixKeyPayload, DecodeErrors) {
  dynamic.decode3(
    CreatePixKeyPayload,
    field("kind", string),
    field("key", string),
    field("accountId", string),
  )(json)
}
