require('dotenv').config();

const express = require('express');
const cors = require('cors');
const path = require('path');
const pool = require('./db/pool');
const leaderboardRoutes = require('./routes/leaderboard');
const predictionRoutes = require('./routes/predictions');

const app = express();
const PORT = parseInt(process.env.PORT || '4000', 10);

app.use(cors());
app.use(express.json());

// Serve static Flutter web files from ./public/web (matches Dockerfile)
app.use(express.static(path.join(__dirname, './public/web')));

app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', db: 'connected' });
  } catch (err) {
    res.status(500).json({ status: 'error', db: 'disconnected' });
  }
});

app.use('/api', leaderboardRoutes);
app.use('/api', predictionRoutes);

// SPA fallback
app.get('*', (_req, res) => {
  res.sendFile(path.join(__dirname, './public/web/index.html'));
});

app.listen(PORT, () => {
  console.log(`⚽ Flappy World Cup backend running on http://localhost:${PORT}`);
  console.log(`   GET  /api/leaderboard`);
  console.log(`   POST /api/scores`);
  console.log(`   POST /api/predictions`);
  console.log(`   GET  /api/predictions/stats`);
});