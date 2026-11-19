# MessMind AI
**Intelligent University Mess Food Demand Forecasting and Waste Reduction System**

FastAPI + SQLite + scikit-learn backend, React + Tailwind + Recharts + Lucide frontend. One deployable service.

> ## Read this first - honesty notes
> 1. **The menu comes from your timetable photo.** `data/menu_timetable.csv` is my transcription of the photograph: 7 days x 4 meals, 249 slots, 148 unique dishes, names kept exactly as printed. 12 dish names that were blurry, cut off or ambiguous are flagged `needs_confirmation` (amber in the UI) instead of guessed: Cold Sandwich, Garlic Tomato Chutney, Moth Bean Sprouts, Soya Paneer Prantha, Pickle, "Mede" Vada with Sambhar, Mixed Cut Fruits, One Sachet, Khuska, Artikai Vepudu, Aloo Shimla, and the Saturday-lunch salad entry that is cut off at the paper's edge. Thursday lunch lists Plain Rice twice - it is stored once. **Please check the whole CSV against the board once**, then fix names under Menu -> Dishes or re-import the corrected CSV.
> 1b. **Serving sizes, take-up rates and recipes are estimates** (`backend/app/catalog.py`, built from recipe archetypes such as "dal", "dry vegetable", "fried snack"). Replace them with the mess's real recipes under Menu -> Dishes; the quantity calculator is only as good as these recipes. "One Sachet" has no recipe on purpose.
> 2. **All records are simulated.** ~9 months of synthetic attendance / consumption / waste are generated for demonstration and flagged `is_synthetic=1`; the UI shows a banner everywhere. The very high R² on simulated data only proves the pipeline works - it says nothing about real accuracy. Record real data, remove the simulated data (Admin page) and retrain to get honest metrics.
> 3. Weather uses seasonal averages by default. Live Open-Meteo weather is optional (`MESSMIND_WEATHER=1`).
> 4. Change all demo passwords and set `MESSMIND_SECRET` before any real deployment.

## Quick start (local)
Requirements: Python 3.10+, Node 18+.
```bash
# 1. backend
cd backend
python -m venv .venv && source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python -m app.seed --reset                               # creates DB, demo users, simulated data, trains + prints model comparison
uvicorn app.main:app --reload --port 8000                # API docs: http://localhost:8000/api/docs

# 2. frontend (new terminal)
cd frontend
npm install
npm run dev                                              # http://localhost:5173  (proxies /api to :8000)
```
Single-service mode (what production uses): `cd frontend && npm install && npm run build`, then run only the backend - it serves `frontend/dist` at http://localhost:8000.

## Demo accounts
| Role | Username / password | Can do |
|---|---|---|
| Admin | `admin` / `admin123` | everything, user management, remove simulated data |
| Mess Manager | `manager` / `manager123` | menu, dishes, planner, models, waste, inventory, reports |
| Staff | `staff` / `staff123` | dashboard, planner, enter waste records, view inventory |
| Student | `student` / `student123` | view menu, submit feedback only (cannot see or change production data) |

## Deploy (web simulation)
**Docker:** `cp .env.example .env` (set `MESSMIND_SECRET`), then `docker compose up --build` -> http://localhost:8000.
**Render / Railway / Fly.io:** push the repo, create a Docker web service (`render.yaml` included), set `MESSMIND_SECRET`. The image seeds a simulated database at build time so the demo works immediately. SQLite on free tiers is ephemeral - attach a disk/volume at `/app/database` and `/app/ml_models` to keep real records.

## Changing the timetable
* Edit one slot: Menu -> Weekly -> `+ add` / `x` on a chip. Edit/confirm a dish: Menu -> Dishes.
* Replace everything: Menu -> **Import** with a CSV of `day,meal,dish,status` (all-or-nothing). Unknown dishes are created flagged and *without* a recipe.
* Special occasions: Menu -> **Special day** overrides one date/meal and can be reverted.
* Re-seeding from the CSV: `python -m app.seed --reset`.

## Using real data
1. Staff enter each meal under **Food Waste -> Enter record** (or Admin -> import CSV).
2. After >= 60 real meal records the models train on real data only. Until then forecasts use the best available (simulated) data or a baseline and say so.
3. Admin -> **Remove simulated data**, then Forecast & Models -> **Retrain**.

## Project structure
```
backend/app/   main.py (REST API+RBAC)  services.py (business logic)  ml.py (training/inference)  catalog.py (dishes, recipes)  seed.py (simulated data)  db.py  security.py  config.py
backend/tests/ test_services.py  test_api.py
frontend/src/  pages/ (Dashboard, Menu, Planner, Forecast, Waste, Inventory, Feedback, Reports, Admin, Landing, Login)  components/  api.js  auth.jsx
data/menu_timetable.csv   database/   ml_models/   docs/
```
Docs: `docs/ARCHITECTURE.md`, `docs/ML_WORKFLOW.md`, `docs/TESTING.md`, `docs/VIVA_AND_PRESENTATION.md`.

## Tests
```bash
cd backend && pytest -q
```
See `docs/TESTING.md` for the manual end-to-end checklist.
