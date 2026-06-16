# ⚽ Flappy World Cup (Flutter + Flame + Express + PostgreSQL)

A World-Cup-themed Flappy Bird clone in **one repo**: the game
(Flutter + Flame), a leaderboard + predictions **backend**
(Express + PostgreSQL), and full **Docker** orchestration.

| Service | URL | Port |
|---------|-----|------|
| **Frontend** (Flutter web, nginx) | http://localhost:8070 | 8070 |
| **Backend** (Express API) | http://localhost:4000 | 4000 |
| **Database** (PostgreSQL) | localhost | 5432 |

## 🌟 Features
- 🎮 Tap-to-jump, pipe dodging, collision detection, scoring
- 👤 **Enter a username** at the start — it drives the scoreboard
- ⚽ The bird is a different **football star each round** (jersey-coloured
  character + name; original art, not photos)
- 🚩 **National flags** for all 48 teams, drawn in-app (no image assets)
- 🏆 **"Who will win the World Cup 2026?"** vote right by the scoreboard —
  all 48 teams **plus Lebanon 🇱🇧 and Manchester United** for fun
- 📊 **Prediction statistics** stored in PostgreSQL (one vote per user,
  re-voting updates your pick) with a live percentage breakdown
- 🟢 3 difficulty levels · 💾 local high scores · 🔊 sound hooks
- 📱 Mobile **and** web-playable

---

## 🐳 Run EVERYTHING with Docker (recommended)

```bash
docker compose up -d --build     # start DB + backend + frontend (detached)
docker compose down              # stop everything
```

- Frontend → http://localhost:8070
- Backend  → http://localhost:4000
- The **database starts fresh from zero every time**: there is **no
  persistent volume**, so `docker compose down` wipes it, and the next
  `up` re-runs `schema.sql` + `seed.sql` automatically.

> The Flutter-web image compiles the app inside Docker, so the **first**
> `--build` is slow (it downloads the Flutter SDK image). Later builds are cached.

Useful:
```bash
docker compose logs -f backend
docker compose logs -f frontend
docker exec -it flappy_db psql -U postgres -d flappy_bird_game -c "SELECT * FROM predictions;"
```

---

## 📁 Folder structure

```
flappy-bird-game/
├── backend/
│   ├── server.js              # Express entry (port 4000)
│   ├── package.json
│   ├── Dockerfile             # backend image
│   ├── .env.example
│   ├── db/{pool.js, schema.sql, seed.sql}
│   └── routes/
│       ├── leaderboard.js     # GET /api/leaderboard, POST /api/scores
│       └── predictions.js     # POST /api/predictions, GET /api/predictions/stats
├── flutter_app/
│   ├── Dockerfile             # builds Flutter web, serves via nginx :8070
│   ├── nginx.conf
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── game/              # flappy_game, bird (footballer), pipe, scenery
│       ├── screens/           # home, game, leaderboard, predictions
│       ├── services/          # api / local sqlite / sound
│       ├── providers/         # settings, leaderboard, prediction
│       ├── models/            # score, difficulty, prediction
│       ├── data/              # world_cup_teams (48+2), football_players
│       └── widgets/           # flag_widget (draws flags)
├── docker-compose.yml         # db + backend + frontend, NO volume (fresh DB)
├── README.md
└── .gitignore
```

---

## 🗄️ EXACT PostgreSQL commands

Run from the project root (default user `postgres`):

```bash
# 1. Create the database
psql -U postgres -c "CREATE DATABASE flappy_bird_game;"

# 2. Connect (interactive shell)
psql -U postgres -d flappy_bird_game

# 3. Run the schema (leaderboard + predictions tables + indexes)
psql -U postgres -d flappy_bird_game -f backend/db/schema.sql

# 4. Seed sample data (scores + predictions, incl. Lebanon & Man United)
psql -U postgres -d flappy_bird_game -f backend/db/seed.sql

# 5. View the leaderboard
psql -U postgres -d flappy_bird_game -c "SELECT * FROM leaderboard;"

# 6. View predictions
psql -U postgres -d flappy_bird_game -c "SELECT * FROM predictions;"

# 7. List tables
psql -U postgres -d flappy_bird_game -c "\dt"

# 8. Drop & reset
psql -U postgres -c "DROP DATABASE IF EXISTS flappy_bird_game;"
```

Prediction stats query (same logic the API uses):
```bash
psql -U postgres -d flappy_bird_game -c \
  "SELECT team, COUNT(*) AS votes FROM predictions GROUP BY team ORDER BY votes DESC;"
```

---

## ▶️ Run LOCALLY (without Docker)

```bash
# A. Database
psql -U postgres -c "CREATE DATABASE flappy_bird_game;"
psql -U postgres -d flappy_bird_game -f backend/db/schema.sql
psql -U postgres -d flappy_bird_game -f backend/db/seed.sql

# B. Backend (port 4000)
cd backend && cp .env.example .env && npm install && npm start

# C. Flutter web (port 8070)
cd flutter_app && flutter pub get && flutter run -d web-server --web-port 8070
#   then open http://localhost:8070
```

> **Android emulator:** the app auto-uses `http://10.0.2.2:4000`.
> **Web/iOS:** `http://localhost:4000`.
> **Physical phone:** set your PC's LAN IP in `lib/services/api_service.dart`.

---

## 🔌 API endpoints

Base URL: `http://localhost:4000`

| Method | Path | Body / Query | Purpose |
|--------|------|--------------|---------|
| GET | `/api/leaderboard` | `?difficulty=&limit=` | Top scores |
| POST | `/api/scores` | `{player_name, score, difficulty}` | Submit a score |
| POST | `/api/predictions` | `{username, team}` | Vote (one per user, upsert) |
| GET | `/api/predictions/stats` | – | Vote counts + percentages |
| GET | `/health` | – | DB health check |

```bash
# Vote
curl -X POST http://localhost:4000/api/predictions \
  -H "Content-Type: application/json" \
  -d '{"username":"Jad","team":"Lebanon"}'

# Stats
curl http://localhost:4000/api/predictions/stats
# -> { "total": 15, "data": [ {"team":"Argentina","votes":4,"percentage":26.7}, ... ] }
```

---

## 🚀 Deployment

**Backend + DB** (Render / Railway / Fly.io): deploy `backend/` as a Node
service (`node server.js`), provision PostgreSQL, set `DB_*` + `PORT` env
vars, then run `schema.sql` + `seed.sql` once against the managed DB.

**Flutter web** (Netlify / static host): `cd flutter_app && flutter build web`,
deploy `build/web/`, and point `baseUrl` in `lib/services/api_service.dart`
at your deployed backend (CORS is already enabled in `server.js`).

---

## 🛠️ Notes
- **Fresh DB each run** is intentional (no Docker volume). If you ever want
  persistence, add a `volumes: - pgdata:/var/lib/postgresql/data` back to the
  `db` service and a top-level `volumes: { pgdata: {} }`.
- **Flags & players are drawn in-app** (colour data + canvas), so there are
  no image assets and they look the same everywhere. Player characters are
  original jersey-coloured birds with names — not real photos.
- **Local SQLite on web:** `sqflite` has no web support, so local high scores
  are session-only on web; the global Postgres leaderboard works everywhere.
- **Sound** is optional: drop `jump.wav`/`score.wav`/`hit.wav` into
  `assets/audio/`; without them the game runs silent.
- **Flame** is pinned to `^1.18`; if pub resolves a newer major with API
  changes, pin the version in `pubspec.yaml`.
