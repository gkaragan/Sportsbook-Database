-- Represents basic account information of the sportsbook users
CREATE TABLE "users" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "username" TEXT NOT NULL UNIQUE,
    "date_joined" NUMERIC NOT NULL,
    PRIMARY KEY("id")
);

-- Represents sporting events that can be bet on through the sportsbook
CREATE TABLE "events" (
    "id" INTEGER,
    "market" TEXT NOT NULL,
    "event" TEXT NOT NULL,
    "scheduled" NUMERIC NOT NULL,
    PRIMARY KEY("id")
);

-- Represents the final result of the sporting events
CREATE TABLE "results" (
    "id" INTEGER,
    "event_id" INTEGER,
    "winner" TEXT,
    "result" TEXT NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("event_id") REFERENCES "events"("id")
);

-- Represents bets placed on the sportsbook
CREATE TABLE "bets" (
    "id" INTEGER,
    "user_id" INTEGER,
    "event_id" INTEGER,
    "bet" TEXT NOT NULL,
    "odds" NUMERIC NOT NULL,
    "stake_amount" NUMERIC NOT NULL,
    "return" NUMERIC DEFAULT NULL,
    "placed" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" TEXT CHECK("status" IN ('open', 'settled')),
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("event_id") REFERENCES "events"("id")
);

-- Represents user deposits and withdrawals from the sportsbook
CREATE TABLE "transactions" (
    "id" INTEGER,
    "user_id" INTEGER,
    "deposit_amount" NUMERIC NOT NULL,
    "withdrawal_amount" NUMERIC NOT NULL CHECK("deposit_amount" = 0 OR "withdrawal_amount" != 0),
    "datetime" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
);


-- Trugger that automatically settles bets when an events result is inserted into the database
CREATE TRIGGER "bet_settlement"
AFTER INSERT ON "results"
BEGIN
UPDATE "bets" SET "status" = 'settled'
WHERE "event_id" = NEW."event_id";
END;


CREATE INDEX "event_index" ON "events" ("event_name", "scheduled");
CREATE INDEX "bets_index" ON "bets" ("event_id", "bet", "status");
CREATE INDEX "user_bets_index" ON "bets" ("user_id", "status");
CREATE INDEX "results_index" ON "results" ("event_id");
