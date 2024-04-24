-- Create tables and types

CREATE TABLE "banks" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "code" VARCHAR(10) NOT NULL,
  "name" VARCHAR(255) NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE "accounts" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "ownerName" VARCHAR(255) NOT NULL,
  "bankId" UUID NOT NULL REFERENCES "banks"("id"),
  "number" VARCHAR(20) NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TYPE "pixKeyKind" AS ENUM ('cpf', 'email', 'phone', 'random');

CREATE TYPE "pixKeyStatus" AS ENUM ('inactive', 'active');

CREATE TABLE "pixKeys" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "kind" "pixKeyKind" NOT NULL,
  "key" VARCHAR(255) NOT NULL,
  "accountId" UUID NOT NULL REFERENCES "accounts"("id"),
  "status" "pixKeyStatus" NOT NULL DEFAULT 'active',
  "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TYPE "transactionStatus" AS ENUM ('pending', 'confirmed', 'complete', 'error');

CREATE TABLE "transactions" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "accountFromId" UUID NOT NULL REFERENCES "accounts"("id"),
  "accountToId" UUID NOT NULL REFERENCES "accounts"("id"),
  "amount" FLOAT NOT NULL,
  "pixKeyToId" UUID NOT NULL REFERENCES "pixKeys"("id"),
  "status" "transactionStatus" NOT NULL DEFAULT 'pending',
  "description" VARCHAR(255),
  "cancelDescription" VARCHAR(255),
  "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT now()
);

-- Insert base records

INSERT INTO "banks" ("code", "name") VALUES
  ('001', 'Santoandré'),
  ('002', 'Banco do Brasil');

INSERT INTO "accounts" ("ownerName", "bankId", "number") VALUES
  ('Matheus Campos', 'e588689a-2c25-44a6-a07f-56a309b457e9', '0010023'),
  ('Maria Eduarda', 'e588689a-2c25-44a6-a07f-56a309b457e9', '0010033'),
  ('Clara Barbosa', '7a2aa13a-9c3d-47bd-a0c2-12c844ab4c28', '0020012');

INSERT INTO "pixKeys" ("kind", "key", "accountId") VALUES
  ('email', 'silva.campos.matheus@gmail.com', '56f9caec-d448-4e46-bd87-e0f52aaf8be2'),
  ('phone', '+551140028922', '53240ac3-25c7-4961-a84a-c0c0ade3a13b');