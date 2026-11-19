# ---- stage 1: build the React frontend ----
FROM node:20-alpine AS web
WORKDIR /web
COPY frontend/package.json ./
RUN npm install --no-audit --no-fund
COPY frontend/ ./
RUN npm run build

# ---- stage 2: FastAPI + built frontend in a single service ----
FROM python:3.12-slim
WORKDIR /app
ENV PYTHONUNBUFFERED=1 MESSMIND_ENV=production
COPY backend/requirements.txt backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt
COPY backend backend
COPY data data
COPY --from=web /web/dist frontend/dist
RUN mkdir -p database ml_models \
 && cd backend && MESSMIND_SECRET=build-time-only-secret-not-used-at-runtime-000 MESSMIND_ENV=dev python -m app.seed --reset
EXPOSE 8000
# MESSMIND_SECRET MUST be supplied at runtime (the app refuses to start in production with the default).
CMD ["sh", "-c", "cd backend && uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
