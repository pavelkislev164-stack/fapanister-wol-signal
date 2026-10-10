# Fapanister Recovery v2

Purpose: independent recovery control plane for Fapanister.

Production Wake-on-LAN stays unchanged and separate.

## Architecture

ChatGPT -> GitHub -> OpenWrt Recovery v2 poller -> authenticated LAN-only Windows Recovery Agent.

Actions currently implemented by the router poller (verified from router/fapanister-recovery-v2-poll):
- STATUS
- RECOVER_DC
- RECOVER_LIRA
- NONE (neutral trigger / no remote action)

Reserved/documented action names, **NOT implemented in router dispatch**:
- RECOVER_MESH
- RECOVER_RUSTDESK
- RECOVER_ALL

Do not send reserved actions expecting recovery; the poller ignores them. No arbitrary shell.

Incident notes (2026-10-08): RECOVER_DC delivery or an ok=True from the Windows agent does not prove hosted Desktop Commander end-to-end connectivity. A Node process may exist while the hosted command channel is unresponsive; hosted Realtime failures are also reported upstream. See private fapanister-wol-bridge/DC-INCIDENT-2026-10-08.md for a safe recovery diagnostic runbook.

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

## Revalidated 2026-10-09 after local connectivity incident

- Windows LAN Recovery Agent and Fapanister DC Watchdog were found stopped despite scheduled tasks being present. They were safely started without reboot. Windows Agent listened only on `192.168.1.169:8765`.
- NEW authenticated end-to-end `STATUS`: GitHub control trigger -> Cudy poller -> HMAC -> Windows Agent; Windows log: `2026-10-09T16:48:46 accepted STATUS from 192.168.1.1; ok=True`. Router response: `DC=1; Lira=Listening; Mesh=Running; RustDesk=Running`.
- `recovery-trigger.txt` reset to `lira-audit-20261009-1649-reset|NONE` and independently confirmed via GitHub.
- Local recovery supervisor and improved watchdog source/runbook are documented in `fapanister-wol-bridge/AUDIT-2026-10-09.md` and `admin/*`. These require an active FAPster interactive session; no logoff/cold-boot re-certification was conducted.
- Production WoL remained unchanged. Recovery v2 strict router action dispatch remains unchanged; STATUS/RECOVER_DC/RECOVER_LIRA only.

## State update 2026-10-10, before reboot test

Read [pre-reboot audit](https://github.com/pavelkislev164-stack/fapanister-wol-bridge/blob/main/PRE-REBOOT-AUDIT-2026-10-10.md) for verification scope and limitations.

- PRODUCTION DC switched after explicit user authorization to `Fapanister Desktop Commander Elevated` (FAPster/Interactive/Highest/PT0S) at 08:02 MSK. Remote ping and real administrative Windows token verified. Protected runtime at `C:\ProgramData\FapanisterDCElevated`.
- Former `Desktop Commander Remote` task PT72H is Disabled. On-demand `Fapanister DC Unlimited Reserve` remains Limited fallback, not production. Windows Recovery DC starter, Watchdog and Supervisor check the elevated task state before invoking limited fallback, avoiding duplicate remote agents when elevation hides process details.
- `Fapanister DC Watchdog` and `Fapanister LAN Recovery V2` now execute fixed local scripts via hidden WScript launchers, with task XML backups saved locally. Both tested Running; agent still binds only `192.168.1.169:8765`. A switch in executable packaging must not be mistaken for a new network endpoint.
- Independent router HMAC allowlist and protocol unchanged. The router does not expose arbitrary shell. **New pre-reboot STATUS after hidden launch** confirmed at 08:59:20 MSK: Windows accepted authenticated STATUS from Cudy 192.168.1.1, router replied ok:true with DC=1, Lira=Listening, Mesh=Running, RustDesk=Running. GitHub trigger restored to `lira-preboot-20261010-0859-reset|NONE`. It validates the HMAC control path at that moment, not pre-logon readiness or external GUI input.
- Separate `Fapanister Recovery Agent SYSTEM` is registered **Disabled** as staging. Do not start it while the old user agent owns port 8765; true pre-logon recovery is not certified.
- Production WoL unchanged. No reboot/logoff after privileged DC switch. Recovery v2 `ok:true` or a live local Node process alone does not prove real hosted DC command connectivity; always perform live ping/remote command.
