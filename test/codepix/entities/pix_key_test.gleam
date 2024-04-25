import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn pix_key_test() {
  1 + 1
  |> should.equal(2)
}
