# Fapanister Recovery v2

Purpose: independent recovery control plane for Fapanister.

Production Wake-on-LAN stays unchanged and separate.

Recovery path:
GitHub -> OpenWrt recovery poller -> LAN-only Windows recovery agent.

Initial allowed actions:
- STATUS
- RECOVER_DC
- RECOVER_LIRA
- RECOVER_MESH
- RECOVER_RUSTDESK
- RECOVER_ALL
- NONE

Security rules:
- no arbitrary shell commands
- unique request IDs and replay protection
- Windows endpoint LAN-only
- authenticated requests
- never store credentials, tokens, cookies, private keys, router secrets or recovery secrets in GitHub

The first deployment phase should implement STATUS and RECOVER_DC only. Expand the allowlist after end-to-end validation.
