import gleam/dynamic.{
  type Dynamic, bit_array, field, float, optional_field, string,
}
import gleam/option.{type Option, None}
import birl.{type Time}
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

pub type TransactionStatus {
  TransactionPending
  TransactionCompleted
  TransactionConfirmed
  TransactionError
}

pub type ValidationError

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
  Ok(transaction)
}

fn get_status_string(status: TransactionStatus) -> String {
  case status {
    TransactionPending -> "pending"
    TransactionCompleted -> "completed"
    TransactionConfirmed -> "confirmed"
    TransactionError -> "error"
  }
}

pub fn get_transaction_return_type() -> fn(Dynamic) ->
  Result(a, dynamic.DecodeErrors) {
  todo
}

type TransactionRow =
  #(
    BitArray,
    BitArray,
    BitArray,
    Float,
    BitArray,
    String,
    String,
    String,
    String,
    String,
  )

pub fn from_row(
  row: TransactionRow,
) -> Result(Transaction, dynamic.DecodeErrors) {
  todo
}
