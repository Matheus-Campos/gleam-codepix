import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn new_transaction() {
  1 + 1
  |> should.equal(2)
}
