require('dotenv').config();

const fs = require('fs');
const path = require('path');
const express = require('express');
const cors = require('cors');
const pool = require('./db/pool');
const leaderboardRoutes = require('./routes/leaderboard');
const predictionRoutes = require('./routes/predictions');

const app = express();
const PORT = parseInt(process.env.PORT || '4000', 10);

app.use(cors());
app.use(express.json());

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

app.use('/api', (_req, res) => {
  res.status(404).json({ error: 'Not found' });
});

const webDir = path.join(__dirname, 'public', 'web');
app.use(express.static(webDir));

app.use((_req, res) => {
  res.sendFile(path.join(webDir, 'index.html'));
});

async function runMigration() {
  try {
    const sql = fs.readFileSync(path.join(__dirname, 'db', 'schema.sql'), 'utf8');
    await pool.query(sql);
    console.log('\u2713 schema ensured');
  } catch (err) {
    console.error('Schema migration failed:', err.message);
  }
}

async function start() {
  await runMigration();
  app.listen(PORT, () => console.log(`Flappy World Cup running on port ${PORT}`));
}

start();