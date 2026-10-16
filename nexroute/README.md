# Nexroute additions to this fork

Everything Nexroute adds lives under `nexroute/`, `.github/workflows/nexroute-*`
and the release-please files, so rebasing on upstream `cowprotocol/services`
stays conflict-free. Upstream workflows are untouched (disable them in this
fork's Actions settings; they target CoW's infrastructure).

## solana-driver

| | |
|---|---|
| Image | `ghcr.io/nexroute/solana-driver` |
| Dockerfile | `nexroute/solana-driver.Dockerfile` (builds only `solana-driver`, cargo-chef layer cache) |
| Build any branch / tag / SHA | Actions → **Nexroute — solana-driver build** → `ref`. Tags `sha-<sha>` + the ref name |
| Push to `main` | builds `sha-<sha>` + `dev-latest` (no deploy) |
| Staging deploy | same workflow, tick `deploy`: rolls `cowswap-staging-solana-driver` on nexroute-api-partners-01 via nexroute-infra |
| Releases | release-please on `main` → PR → tag `solana-driver-vX.Y.Z` → image `:X.Y.Z` + `:latest` |
| Runtime config | rendered by nexroute-infra (`roles/cowswap-api`, `driver:` block of `cowswap-staging-solana`) |

Repo secrets for the deploy job: `DEPLOY_SSH_KEY`, `ANSIBLE_VAULT_PASSWORD`,
`DISCORD_WEBHOOK_URL` (same values as nexroute/cowswap).
