-- NatureVital local database schema (v1)
-- Executed by lib/data/local/app_database.dart.
-- Each statement must end with a semicolon terminator.
-- Full-line comments (starting with two dashes) are stripped before execution.

CREATE TABLE users (
  uid          TEXT PRIMARY KEY,
  displayName  TEXT NOT NULL,
  calorieGoal  REAL NOT NULL,
  waterGoal    REAL NOT NULL
);

CREATE TABLE logs (
  id          TEXT PRIMARY KEY,
  userId      TEXT NOT NULL,
  timestamp   INTEGER NOT NULL,
  type        TEXT NOT NULL CHECK (type IN ('food','water')),
  calories    REAL,
  description TEXT,
  imageUrl    TEXT,
  protein     REAL,
  carbs       REAL,
  fat         REAL,
  amount      REAL
);

CREATE INDEX idx_logs_user_ts ON logs(userId, timestamp DESC);
