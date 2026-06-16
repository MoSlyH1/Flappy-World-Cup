// ============================================================
// server.js  —  Express entry point (listens on PORT, default 4000)
// ============================================================
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const pool = require('./db/pool');
const leaderboardRoutes = require('./routes/leaderboard');
const predictionRoutes = require('./routes/predictions');

const app = express();
const PORT = parseInt(process.env.PORT || '4000', 10);

// --- middleware ---
app.use(cors()); // allow the Flutter web app (port 8070) + mobile clients
app.use(express.json());

// --- health check ---
app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', db: 'connected' });
  } catch (err) {
    res.status(500).json({ status: 'error', db: 'disconnected' });
  }
});

// --- API routes ---
app.use('/api', leaderboardRoutes);
app.use('/api', predictionRoutes);


// Serve static files
app.use(express.static(path.join(__dirname, '../flutter_app/build/web')));

// SPA fallback
app.get('*', (_req, res) => {
  res.sendFile(path.join(__dirname, '../flutter_app/build/web/index.html'));
});

app.listen(PORT, () => {
  console.log(`⚽ Flappy World Cup backend running on http://localhost:${PORT}`);
  console.log(`   GET  /api/leaderboard`);
  console.log(`   POST /api/scores`);
  console.log(`   POST /api/predictions`);
  console.log(`   GET  /api/predictions/stats`);
});
