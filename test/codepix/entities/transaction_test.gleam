import gleeunit
import gleeunit/should
import gleam/option.{None}
import ids/uuid
import codepix/entities/transaction

pub fn main() {
  gleeunit.main()
}

pub fn new_transaction() {
  let assert Ok(account_from_id) = uuid.generate_v4()

  let assert Ok(transaction) =
    transaction.new(
      from: account_from_id,
      to_key: "silva.campos.matheus@gmail.com",
      amount: 60.0,
      description: None,
    )

  transaction.amount
  |> should.equal(60.0)

  transaction.description
  |> should.equal(None)

  transaction.account_from_id
  |> should.equal(account_from_id)

  transaction.pix_key_to_id
  |> should.equal("silva.campos.matheus@gmail.com")

  transaction.status
  |> should.equal("pending")

  transaction.cancel_description
  |> should.equal(None)
}
