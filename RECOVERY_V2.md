# Fapanister Recovery v2

Purpose: independent recovery control plane for Fapanister.

Production Wake-on-LAN stays unchanged and separate.

## Architecture

ChatGPT -> GitHub -> OpenWrt Recovery v2 poller -> authenticated LAN-only Windows Recovery Agent.

Current allowlist:
- STATUS
- RECOVER_DC
- RECOVER_LIRA
- RECOVER_MESH
- RECOVER_RUSTDESK
- RECOVER_ALL
- NONE

No arbitrary shell.

## Security

- unique request IDs
- timestamp freshness validation
- nonce replay protection
- HMAC-SHA256 authentication
- Windows endpoint bound to 192.168.1.169:8765
- recovery secret stored locally only, never in GitHub
- router recovery service separate from production WoL
- no WAN exposure for the Windows Recovery Agent

## OpenWrt implementation

Service: fapanister-recovery-v2

Router source files:
- router/fapanister-recovery-v2-poll
- router/fapanister-hmac.uc
- router/fapanister-recovery-v2-init

The poller uses GitHub Contents API with Accept: application/vnd.github.raw+json.
raw.githubusercontent.com is not used for the control path because stale content was observed during testing.

## Certified 2026-10-07

STATUS:
GitHub -> Cudy/OpenWrt -> HMAC-SHA256 -> Windows Recovery Agent -> STATUS succeeded.
Windows log confirmed accepted STATUS from 192.168.1.1.
Unsigned traffic was separately tested and correctly rejected.

RECOVER_DC:
1. Healthy RECOVER_DC succeeded while Desktop Commander was online.
2. Controlled failure certification:
   - normal Desktop Commander startup script was temporarily moved aside;
   - Desktop Commander remote processes were terminated;
   - a DC tool call timed out, confirming loss of the primary channel;
   - fresh RECOVER_DC was sent through GitHub;
   - Windows Recovery Agent accepted RECOVER_DC from 192.168.1.1;
   - Desktop Commander returned via the dedicated recovery script;
   - normal startup script was restored;
   - GitHub trigger returned to NONE.

Independent RECOVER_DC is CERTIFIED.

Dedicated recovery script:
C:\Users\FAPster\RecoveryV2\Recover-DesktopCommander.ps1

RECOVER_LIRA:
1. Healthy RECOVER_LIRA succeeded while LiraBrowser was listening on 127.0.0.1:9333.
2. Controlled failure certification:
   - normal Start-LiraBrowser.ps1 was temporarily moved aside so the scheduled task could not be the recovery source;
   - only Chrome processes using C:\Users\FAPster\LiraBrowser\Profile were terminated;
   - port 9333 was verified DOWN and matching Chrome process count became 0;
   - fresh RECOVER_LIRA was sent through GitHub;
   - Windows Recovery Agent accepted RECOVER_LIRA from 192.168.1.1 with ok=True;
   - port 9333 returned LISTENING;
   - LiraBrowser reopened using the same persistent profile;
   - Playwright reattached to https://tilda.ru/projects/;
   - post-recovery check showed no password field and no login prompt, confirming the existing Tilda session survived;
   - normal Start-LiraBrowser.ps1 was restored;
   - GitHub trigger returned to NONE.

Independent RECOVER_LIRA is CERTIFIED.

Dedicated recovery script:
C:\Users\FAPster\RecoveryV2\Recover-LiraBrowser.ps1

## Administrative route separation

Classic Windows OpenSSH launched directly from the Desktop Commander session still returns exit 255.

A permanent local administrative route was certified on 2026-10-07:

Desktop Commander -> Windows/Node.js -> ssh2 -> Cudy/OpenWrt

Classification: ADMIN / RESERVE.

Local runtime:
C:\\Users\\FAPster\\CudyAdmin

The route:
- uses the existing local ED25519 recovery key without copying it to GitHub;
- pins the Cudy ED25519 host key;
- creates no Windows listener;
- keeps router SSH LAN-only;
- was verified with live OpenWrt system-board and release queries.

This route is intentionally separate from Recovery v2.
Recovery v2 keeps a strict action allowlist and MUST NOT become an arbitrary-shell control plane.

Runbook and safe source are stored in:
pavelkislev164-stack/fapanister-wol-bridge / CUDY-ADMIN.md and admin/*

## Next

1. RECOVER_MESH is optional/reserve work rather than a core blocker.
2. RustDesk laptop input test when useful.
3. Use the certified local CudyAdmin route for router diagnostics/maintenance.
4. Final cold-boot/WoL/Recovery v2/CudyAdmin/security audit when desired.
