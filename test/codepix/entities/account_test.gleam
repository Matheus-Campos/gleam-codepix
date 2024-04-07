import gleeunit
import gleeunit/should
import ids/uuid
import codepix/entities/account

pub fn main() {
  gleeunit.main()
}

pub fn new_account_test() {
  let assert Ok(bank_id) = uuid.generate_v4()
  let assert Ok(account) = account.new("Matheus", bank_id, "30213")

  account.owner_name
  |> should.equal("Matheus")

  account.bank_id
  |> should.equal(bank_id)

  account.number
  |> should.equal("30213")
}
