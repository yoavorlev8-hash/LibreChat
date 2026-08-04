#!/bin/sh
# Base44 dev entrypoint: runs the Express backend (nodemon) and the Vite dev
# server in a single container so Vite's /api proxy can reach the backend on
# the same host (0.0.0.0:3080). Vite (port 3090) is the foreground process and
# is mapped to host port 3000.
set -e

cd /app
touch /app/.env

echo "[base44] starting backend (nodemon) on 0.0.0.0:3080 ..."
PORT=3080 HOST=0.0.0.0 npm run backend:dev &

echo "[base44] starting client (vite) on 0.0.0.0:3090 ..."
cd /app/client
export PORT=3090 HOST=0.0.0.0
exec npm run dev
