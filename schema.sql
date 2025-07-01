# Design Document

Sportsbook Database

By George Karagan

Video overview: <https://youtu.be/i_6CkicHP3s?si=O7FeB3RcaTjr-duU>

## Scope

The sportsbook database contains all entities required to log user account information, their bets on sporting events, and information pertaining to these sporting events. For those unfamiliar with sports betting, a sportsbook is a platform through which people can place wagers (i.e., bets) on the outcome of sporting events. The purpose of the sportsbook database is to store the important information that any real-world sportsbooks should contain.

Included in the databases scope is:

* Users, including basic account information
* Events, including the market (i.e., league), name, and scheduled time of the sporting event
* Results of the sporting events, including the winner
* Bets, including the amount staked, won, and the odds of the bet
* Transactions, including deposits and withdrawals from the sportsbook

Outside of the database's scope are player performance bets; since the `results` entity does not support player performances, but only winners and final scores.

## Functional Requirements

The database supports CRUD operations for all entities. Users of the database (i.e., employees of the sportsbook) can log important user information when an individual signs up with the sportsbook, including their first/last name and username. Moreover, all the bets that a user makes through the sportsbook and any important information pertaining to the bets can be logged. On the inserting of data into the `results` table, bets on that particular event will be automatically marked as 'settled' using a trigger. However, the `return` column in the `results` table must be manually updated by the database user to indicate the amount of money that the person placing the bet will receive as winnings. That is to say that users of the database must verify that the bet has won or lost by monitoring the `results` table. For winning bets, the return is calculated by the formula return = stake * odds (where the odds are in decimal format). For losing bets the return is 0. Users of the database can also track a sportsbook users financial transactions (i.e., withdrawals and deposits). The database will not support the current balance in sportsbook users' accounts or the labeling of bets as 'winning' or 'losing', however, this can be inferred based on the value of the `return` column. Any data inserted into the `transactions` table must include a '0' for either the `deposit_amount` or `withdrawal_amount` column (but not both). This allows the use of aggregate functions on these columns since there are no NULL cells.


## Representation

Entities are included in the following tables

### Entities

#### Users

The `users` table includes the following columns:

* `id`, which is the unique `INTEGER` id given to each user who signs up with the sportsbook. This column and each `id` column for the subsequent tables have the `PRIMARY KEY` constraint applied.
* `first_name`, which specifies a users first name as `TEXT`.
* `last_name`,  which specifies a users last name as `TEXT`.
* `username`, which specifies the sportsbook users `UNIQUE` username that identifies their account as `TEXT`.
* `date_joined`, which specifies the date that the user signed up with the sportsbook. It is of the `NUMERIC` type in order to support dates formatted as 'YYYY-MM-DD'.

#### Events

The `events` table contains the following columns:

* `id`, which is the `INTEGER` `PRIMARY KEY` specifying the unique id for each sporting event that may be bet on through the sportsbook.
* `market`, which specifies as `TEXT` the market of the sporting event (i.e., NBA, NFL, UFC, NHL ...).
* `event`, which specifies the title of the event as `TEXT`. For example, a MLB game might be stored in the `event` column as 'TOR Bluejays vs NY Yankees'.
* `scheduled`, which specifies the datetime of the scheduled event. This column has type `NUMERIC` which can conveniently store datetime values.

#### Results

The results table includes the following columns:

* `id`, which specifies the id of the sporting event result, similarly to the previous `id` columns.
* `event_id`, which specifies the `id` of the event that the result applies to. The `FOREIGN KEY` constraint is applied to this column, referencing the `events` table.
* `winner`, which specifies the winner of the particular event as `TEXT`. Note that there is no `NOT NULL` condition because some events may end in a draw for which the column value would be `NULL`.
* `result`, which specifies the final result of the event as `TEXT`. This is the outcome, or in most cases, the final score of the event (e.g., '7-6', 'DRAW', 'KO', '103-100').

#### Bets

The `bets` table contains the following columns:

* `id`, which is the `INTEGER` `PRIMARY KEY` uniquely identifying each bet
* `user_id`, which is the `FOREIGN KEY` referencing the `users` table, allowing a bet to be associated to a user.
* `event_id`, which is the `FOREIGN KEY` referencing the `events` table, allowing a bet to be associated to an event.
* `bet`, which specifies as `TEXT` the bet that a user places on a particular event.
* `odds`, which specify the odds of the bet in decimal format. The column has type `NUMERIC` as this type conveniently covers floating point values.
* `stake_amount`, which specifies the amount of money the user placed on a particular bet. The type is again `NUMERIC` for the same reason as the `odds` column.
* `return`, which specifies the return that the user made on the bet as a `NUMERIC` value. Note that this column has a `DEFAULT NULL` value because bets are first listed as open, until the sporting event has finished, after which the bet may be settled (by our trigger). In particular, a user has no return until the bet is confirmed to win or lose. When the result is confirmed, the value may be changed from `NULL` to the actual return.
* `placed`, which specifies the date and time the bet is placed. The type is `NUMERIC` since this type handles datetimes, and the `DEFAULT` value is the `CURRENT_TIMESTAMP` which gives the current date and time.
* `status`, which specifies as `TEXT`, the status of the bet. The `CHECK` condition is used to ensure the status is either 'open' or 'closed'.

#### Transactions

The `transactions` table contains the following columns:

* `id`, which is the `INTEGER` `PRIMARY KEY` uniquely identifying each financial transaction a user makes.
* `user_id`, which is the `FOREIGN KEY` referencing the `users` table and allows the association of a transaction to a user.
* `deposit_amount`, which specifies the amount that a user is depositing on a particular transaction. If they are making a withdrawal instead then the value should be inserted as 0 for this column. The column has type `NUMERIC` to represent any amount of money.
* `withdrawal_amount`, which specifies the amount a user is to withdraw. Similarly, it has type `NUMERIC`. Note that the `CHECK` condition ensures that one of the `deposit_amount` and `withdrawal_amount` columns have a value of 0 for a particular transaction. This is to enable the application of aggregate functions on these columns.
* `datetime`, which specifies the date and time of the financial transaction, again using the type `NUMERIC` and having `DEFAULT` value `CURRENT_TIMESTAMP`.

Unless otherwise specified, each column has the `NOT NULL` constraint applied in all tables.

### Relationships

![diagram](diagram.png)

As can be seen from the ER diagram:

* One sportsbook user is capable of making 0 to many bets. 0 only if they have yet to make a bet on the sportsbook. On the other hand, a bet can only be made by a single user (although, in the `bets` table different users can have the same `bet`).
* An event has one, and only one result. Similarly, any result is associated with a single event.
* An event can have 0 to many bets placed on it. Alternatively, any bet corresponds to exactly one event (The model does not support sports parlays or, multiple bets in one).
* Any user can make 0 to many transactions through the sportsbook, however, every transaction is associated with a single user.

## Optimizations

As users of the database must confirm if a bet has won or lost, they will often run a query to search the `results` table by `event_id` and the `events` table by `event_name` and `scheduled`. Because of this, an index was created for the `event_name` and `scheduled` columns as well as the `event_id` column. Once the outcome of a bet is confirmed, database users must update the `return` column in the `bets` table. Since this happens for every bet, an index was made for the `event_id`, `bet` and `status` columns to speed the process. Finally, since it is common to check the bets a user has made, an index was created for the `status` and `user_id` columns of the `bets` table. This speeds the search of a users bets (open or settled) by their id.

## Limitations

As previously discussed, the current design does not allow for player performance bets. This is because the `results` table only stores data relating to the final outcome (or score) and winner of the event. This `results` table was included to illustrate the process of bet settlment. Real world sportsbooks likely utilize APIs from big sports corporations like the NBA NHL and NFL to be informed of the results of events, rather than storing these results within their own databases. This can save alot of storage space within the database, but will cost a substantial amount. The current model can support parlays (or the combination of multiple bets into a single bet), but for convenience we assume sportsbook users will only place straight bets to save storage space. Another limitation is that database users must manually update the `return` column of the `bets` table rather than it being automated.

