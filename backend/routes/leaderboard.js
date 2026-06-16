// ============================================================
// routes/leaderboard.js  —  Leaderboard API routes
// ============================================================
//   GET  /api/leaderboard?difficulty=hard&limit=10
//   POST /api/scores            { player_name, score, difficulty }
// ============================================================
const express = require('express');
const pool = require('../db/pool');

const router = express.Router();

const VALID_DIFFICULTIES = ['easy', 'medium', 'hard'];

// ------------------------------------------------------------
// GET /api/leaderboard
// Optional query params:
//   difficulty -> easy | medium | hard  (omit for all)
//   limit      -> number of rows (default 10, max 100)
// ------------------------------------------------------------
router.get('/leaderboard', async (req, res) => {
  try {
    const { difficulty } = req.query;
    let limit = parseInt(req.query.limit || '10', 10);
    if (Number.isNaN(limit) || limit < 1) limit = 10;
    if (limit > 100) limit = 100;

    let result;
    if (difficulty && VALID_DIFFICULTIES.includes(difficulty)) {
      result = await pool.query(
        `SELECT id, player_name, score, difficulty, created_at
           FROM leaderboard
          WHERE difficulty = $1
          ORDER BY score DESC, created_at ASC
          LIMIT $2`,
        [difficulty, limit]
      );
    } else {
      result = await pool.query(
        `SELECT id, player_name, score, difficulty, created_at
           FROM leaderboard
          ORDER BY score DESC, created_at ASC
          LIMIT $1`,
        [limit]
      );
    }

    res.json({ count: result.rows.length, data: result.rows });
  } catch (err) {
    console.error('GET /leaderboard error:', err);
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

// ------------------------------------------------------------
// POST /api/scores
// Body: { player_name: string, score: number, difficulty: string }
// ------------------------------------------------------------
router.post('/scores', async (req, res) => {
  try {
    let { player_name, score, difficulty } = req.body;

    // --- validation ---
    if (typeof player_name !== 'string' || player_name.trim().length === 0) {
      return res.status(400).json({ error: 'player_name is required' });
    }
    player_name = player_name.trim().slice(0, 50);

    score = parseInt(score, 10);
    if (Number.isNaN(score) || score < 0) {
      return res.status(400).json({ error: 'score must be a non-negative integer' });
    }

    if (!VALID_DIFFICULTIES.includes(difficulty)) {
      difficulty = 'easy';
    }

    const result = await pool.query(
      `INSERT INTO leaderboard (player_name, score, difficulty)
       VALUES ($1, $2, $3)
       RETURNING id, player_name, score, difficulty, created_at`,
      [player_name, score, difficulty]
    );

    res.status(201).json({ data: result.rows[0] });
  } catch (err) {
    console.error('POST /scores error:', err);
    res.status(500).json({ error: 'Failed to submit score' });
  }
});

module.exports = router;
