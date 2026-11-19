#!/usr/bin/env bash
# Starts backend (8000) and frontend dev server (5173). Run after the one-time setup in README.md.
set -e
(cd backend && uvicorn app.main:app --reload --port 8000) &
(cd frontend && npm run dev)
