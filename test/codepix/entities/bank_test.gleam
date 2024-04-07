import gleeunit
import gleeunit/should
import codepix/entities/bank

pub fn main() {
  gleeunit.main()
}

pub fn new_bank_test() {
  let assert Ok(bank) = bank.new("3000", "Santoandré")

  bank.code
  |> should.equal("3000")

  bank.name
  |> should.equal("Santoandré")
}
