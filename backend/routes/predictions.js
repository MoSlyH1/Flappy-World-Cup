// ============================================================
// routes/predictions.js  —  World Cup winner predictions
// ============================================================
//   POST /api/predictions        { username, team }  (upsert)
//   GET  /api/predictions/stats   -> vote counts + percentages
// ============================================================
const express = require('express');
const pool = require('../db/pool');

const router = express.Router();

// ------------------------------------------------------------
// POST /api/predictions
// One vote per username. Re-voting updates the existing pick.
// ------------------------------------------------------------
router.post('/predictions', async (req, res) => {
  try {
    let { username, team } = req.body;

    if (typeof username !== 'string' || username.trim().length === 0) {
      return res.status(400).json({ error: 'username is required' });
    }
    if (typeof team !== 'string' || team.trim().length === 0) {
      return res.status(400).json({ error: 'team is required' });
    }
    username = username.trim().slice(0, 50);
    team = team.trim().slice(0, 60);

    const result = await pool.query(
      `INSERT INTO predictions (username, team)
       VALUES ($1, $2)
       ON CONFLICT (username)
       DO UPDATE SET team = EXCLUDED.team, updated_at = NOW()
       RETURNING id, username, team, updated_at`,
      [username, team]
    );

    res.status(201).json({ data: result.rows[0] });
  } catch (err) {
    console.error('POST /predictions error:', err);
    res.status(500).json({ error: 'Failed to save prediction' });
  }
});

// ------------------------------------------------------------
// GET /api/predictions/stats
// Returns each team's vote count + percentage, highest first.
// ------------------------------------------------------------
router.get('/predictions/stats', async (_req, res) => {
  try {
    const totalRes = await pool.query('SELECT COUNT(*)::int AS total FROM predictions');
    const total = totalRes.rows[0].total;

    const result = await pool.query(
      `SELECT team, COUNT(*)::int AS votes
         FROM predictions
        GROUP BY team
        ORDER BY votes DESC, team ASC`
    );

    const data = result.rows.map((row) => ({
      team: row.team,
      votes: row.votes,
      percentage: total > 0 ? Math.round((row.votes / total) * 1000) / 10 : 0,
    }));

    res.json({ total, data });
  } catch (err) {
    console.error('GET /predictions/stats error:', err);
    res.status(500).json({ error: 'Failed to fetch prediction stats' });
  }
});

module.exports = router;
