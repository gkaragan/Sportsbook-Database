-- queries the results of a particular sporting event
-- note that in some sports "event_name" can be repeated, so "scheduled" allows perfect description of the event
-- the results of an event are required to settle sports bets placed on the event
SELECT "winner", "result" FROM "results"
WHERE "event_id" = (
    SELECT "id" FROM "events"
    WHERE "event_name" = 'LA Lakers vs BOS Celtics'
    AND "scheduled" = '09-01-2024 19:30'
);


-- see if a user has been profitable throughout their career with the sportsbook
SELECT SUM("withdrawal_amount") - SUM("deposit_amount") AS "net_total" FROM "transactions"
WHERE "user_id" = (
    SELECT "id" FROM "users"
    WHERE "username" = 'georgekaragan'
);


-- see a users settled bets from most recent to least recent (similar for open bets)
SELECT "bet", "placed", "stake_amount", "return" FROM "bets"
WHERE "status" = 'settled' AND "user_id" = 1
ORDER BY "placed" DESC;


-- updates the database after a user makes a winning bet on an event
-- "stake_amount" * "odds" is the mathematical formula for the return on a winning bet
UPDATE "bets" SET "return" = "stake_amount" * "odds"
WHERE "event_id" = (
    SELECT "id" FROM "events"
    WHERE "event_name" = 'LA Lakers vs BOS Celtics' AND "scheduled" = '09-01-2024 19:30'
)
AND "bet" = 'LA Lakers ML' AND "status" = 'settled';


-- updates the database after a user makes a losing bet on an event
-- if a bet loses, then the return is 0 (i.e., the user loses their money)
-- the lakers are the winning team, so users that bet Celtics moneyline lose the bet
UPDATE "bets" SET "return" = 0
WHERE "event_id" = (
    SELECT "id" FROM "events"
    WHERE "event_name" = 'LA Lakers vs BOS Celtics' AND "scheduled" = '09-01-2024 19:30'
)
AND "bet" = 'BOS Celtics ML' AND "status" = 'settled';


-- queries the total amount of money that users on the sportsbook bet on each sporting event
SELECT "event_name", "scheduled", SUM("stake_amount") AS "total_money_bet" FROM "events"
JOIN "bets" on "bets"."event_id" = "events"."id"
GROUP BY "event_id"
ORDER BY "scheduled" DESC;


-- find user id given username
SELECT "id" FROM "users"
WHERE "username" = 'georgekaragan';

