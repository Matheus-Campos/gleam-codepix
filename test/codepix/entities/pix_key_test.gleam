import gleeunit
import gleeunit/should
import ids/uuid
import codepix/entities/pix_key.{
  CpfKind, EmailKind, InvalidKind, InvalidStatus, PixKey, is_valid,
}

pub fn main() {
  gleeunit.main()
}

pub fn new_email_pix_key_test() {
  let assert Ok(account_id) = uuid.generate_v4()
  let assert Ok(pix_key) =
    pix_key.new(EmailKind, account_id, "silva.campos.matheus@gmail.com")

  pix_key.kind
  |> should.equal("email")

  pix_key.account_id
  |> should.equal(account_id)

  pix_key.key
  |> should.equal("silva.campos.matheus@gmail.com")
}

pub fn new_cpf_pix_key_test() {
  let assert Ok(account_id) = uuid.generate_v4()
  let assert Ok(pix_key) =
    pix_key.new(CpfKind, account_id, "silva.campos.matheus@gmail.com")

  pix_key.kind
  |> should.equal("cpf")
}

pub fn invalid_kind_test() {
  let assert Ok(account_id) = uuid.generate_v4()
  let assert Ok(pix_key) =
    pix_key.new(CpfKind, account_id, "silva.campos.matheus@gmail.com")

  let pix_key = PixKey(..pix_key, kind: "other")

  pix_key
  |> is_valid
  |> should.be_error()
  |> should.equal(InvalidKind)
}

pub fn invalid_status_test() {
  let assert Ok(account_id) = uuid.generate_v4()
  let assert Ok(pix_key) = pix_key.new(CpfKind, account_id, "000.000.000-00")

  let pix_key = PixKey(..pix_key, status: "other")

  pix_key
  |> is_valid
  |> should.be_error()
  |> should.equal(InvalidStatus)
}
