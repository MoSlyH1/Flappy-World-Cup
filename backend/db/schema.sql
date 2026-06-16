-- ============================================================
-- schema.sql  —  Flappy World Cup schema
-- ============================================================
-- Auto-loaded by the postgres container on every boot, because
-- docker-compose runs WITHOUT a persistent volume (fresh DB each
-- `docker compose up`). You can also run it manually:
--   psql -U postgres -d flappy_bird_game -f backend/db/schema.sql
-- ============================================================

-- ---------- Leaderboard (game scores) ----------
CREATE TABLE IF NOT EXISTS leaderboard (
    id           BIGSERIAL PRIMARY KEY,
    player_name  VARCHAR(50)  NOT NULL,
    score        INTEGER      NOT NULL CHECK (score >= 0),
    difficulty   VARCHAR(10)  NOT NULL DEFAULT 'easy'
                 CHECK (difficulty IN ('easy', 'medium', 'hard')),
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_leaderboard_score
    ON leaderboard (score DESC);
CREATE INDEX IF NOT EXISTS idx_leaderboard_difficulty
    ON leaderboard (difficulty);
CREATE INDEX IF NOT EXISTS idx_leaderboard_diff_score
    ON leaderboard (difficulty, score DESC);

-- ---------- World Cup winner predictions ----------
-- One vote per username (re-voting updates the existing pick).
CREATE TABLE IF NOT EXISTS predictions (
    id          BIGSERIAL PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE,
    team        VARCHAR(60)  NOT NULL,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_predictions_team
    ON predictions (team);
