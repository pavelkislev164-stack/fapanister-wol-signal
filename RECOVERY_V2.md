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
1. Healthy RECOVER_DC succeeded while Desktop Commander was already online.
2. Controlled failure certification:
   - normal Desktop Commander startup script was temporarily moved aside so Task Scheduler could not be the recovery source;
   - Desktop Commander remote processes were terminated;
   - a DC tool call timed out, confirming loss of the primary channel;
   - a fresh RECOVER_DC was sent through GitHub;
   - Windows Recovery Agent accepted RECOVER_DC from 192.168.1.1;
   - Desktop Commander returned with a new process chain using the dedicated recovery script;
   - the normal startup script was restored;
   - GitHub trigger was reset to NONE.

Independent RECOVER_DC is CERTIFIED.

Windows dedicated recovery script:
C:\Users\FAPster\RecoveryV2\Recover-DesktopCommander.ps1

## Next

1. Implement and certify RECOVER_LIRA without replacing or deleting the persistent browser profile.
2. Then implement RECOVER_MESH and RECOVER_RUSTDESK.
3. Final cold-boot/recovery/security audit.
