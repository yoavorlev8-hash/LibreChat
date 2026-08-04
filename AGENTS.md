# LibreChat — Base44 dev setup

See CLAUDE.md for the project's own conventions. Base44-specific notes below.

## Running in the sandbox

- Start: `docker compose -f docker-compose.base44.yml up -d`
- Preview: host port 3000 → Vite dev server (port 3090 in the `app` container).
- Stack: `mongodb` (mongo:7), `setup` (one-shot: `npm ci` + `npm run build:packages` + a
  placeholder `client/dist/index.html`), `app` (runs the Express backend via nodemon on
  0.0.0.0:3080 AND the Vite dev server on 0.0.0.0:3090 in one container via
  `scripts/base44-dev.sh`).

## Why backend + frontend share one container

The Vite dev server proxies `/api` and `/oauth` to `http://${HOST}:${BACKEND_PORT}`
(see `client/vite.config.ts`). `HOST` is used for BOTH the Vite listen address and the
backend proxy target, so they must share a host. Running both processes in one container
with `HOST=0.0.0.0` makes the proxy target `http://0.0.0.0:3080`, which reaches the
backend in the same container.

## Why a placeholder `client/dist/index.html` exists

`api/server/index.js` unconditionally `fs.readFileSync`s `client/dist/index.html` at
startup (SPA fallback). In dev the real frontend is served by Vite (live source); the
built `dist` is never served. The setup service emits a minimal placeholder so the
backend boots. Do NOT delete `client/dist/index.html`.

## External host access (Vite)

Vite blocks unknown Host headers. `VITE_ALLOWED_HOSTS=3000-${BASE44_PUBLIC_HOST_SUFFIX}`
is passed via compose `environment:` so the preview proxy hostname is allowed.

## Secrets

None required to boot. LibreChat ships default values for `CREDS_KEY`/`JWT_SECRET`/
`JWT_REFRESH_SECRET` (it logs warnings); fresh generated values are set in the compose
`environment:`. AI provider keys (OpenAI, Anthropic, …) are NOT needed at boot — users
add them through the UI after logging in. `ALLOW_REGISTRATION=true` is set so you can
sign up and use the app.

## Verifying it works

- `curl -sf -H "Host: 3000-${BASE44_PUBLIC_HOST_SUFFIX}" http://localhost:3000/` → 200, HTML with `/@vite/client` (live source).
- `curl -sf -H "Host: 3000-..." http://localhost:3000/api/config` → JSON with `"registrationEnabled":true`.
- Backend log: `Server readiness checks passing.`
