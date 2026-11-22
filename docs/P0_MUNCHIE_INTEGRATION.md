# P0 — Zombie Munchie integration / handoff (2026-11-22)

**Status: PARTIAL — code authored on branch, never tested in Roblox Studio, not merged or published.** 
Owner has authorized three actions in chat on 2026-11-22: test palette FBX import, implement P0 server NPC/spatula, and publish seven Munchie animations. Do not request that permission again. Follow the repo's owner-only safety rules before operations in Studio.

## Verified source and target

- Repository: `ortizfram/DEFEND_THE_PIZZA_GAME`; original main commit `acbdba764990384eb0667a3d8a1ef8686063762f`.
- Approved Place from asset brief: **Defend The Pizza**, PlaceId `122513508386436`.
- Existing rig source: `tools/studio/rig_munchie_a.luau` (12 Motor6Ds, 9 WeldConstraints).
- Existing local animation source: `tools/studio/munchie_animations.luau`; seven KeyframeSequences were created in `ServerStorage.RBX_ANIMSAVES.Zombie_Munchie_A` in an unsaved Edit session.
- `art/export/Zombie_Munchie_A.fbx` already has a packed palette image verified by Blender roundtrip. **Not verified in Studio after palette re-export**.
- `default.project.json` restricts live Rojo sync with `servePlaceIds`. The server script also checks the exact PlaceId before mutating anything.

## New P0 scripts

- `src/server/MunchieP0.server.luau`: only active in approved Place. It registers an already-rigged `Workspace.Zombie_Munchie_A`; unanchors the root for Play; sets network ownership on the server; makes the NPC approach `DTP_PizzaTarget`, bite after 2.5 seconds, and consume one visual slice per bite. Creates a disposable 8-slice pizza graybox at runtime only if no authored target exists. A short-range frontal cone and timing check validates the slap request entirely on the server. Hit 1 staggers, hit 2 launches with physics and removes the NPC. Never trusts client-supplied damage or targets.
- `src/client/SpatulaP0.client.luau`: HIT on left mouse, E, controller R2 and touch button; cosmetic BONK/WHAM shown only after server-validated hit. **A 3D spatula and chef swing animation are NOT implemented.**
- `src/shared/Config.luau`: all proposed values centralized. Empty animation IDs mean the server will attempt **Studio-only** temporary playback from existing KeyframeSequences; published IDs must be filled only after actual Roblox upload.
- `default.project.json`: PlaceId gate for Rojo live sync. No `Workspace` objects tracked by Rojo; the graybox is runtime only.
- Server events: `DTP_SpatulaHitValidated`, `DTP_MunchieLaunched`, onboarding `Joined`, `FirstAttackValidated`, `FirstKnockback`. Event calls are wrapped in `pcall` and are **not confirmed to appear in Analytics** until verified in a published, authorized Place.

## Work required in actual Studio, in strict order

1. **Check identity and backup:** confirm PlaceId `122513508386436`, save an independent backup first, verify main Git SHA and local unsaved changes. Claude Code is the only agent allowed to drive that Studio session (AGENTS.md). No Roblox publishing or asset deletions before a safe backup.
2. **Palette re-import:** import the existing `art/export/Zombie_Munchie_A.fbx` with same Import 3D options. Verify green/mint/red/white palette arrives automatically and scale is **3.26 W × 4.74 H × 3.37 D studs**. It appears as a second model. Do not remove old rig before testing; avoid ambiguity from identical names. If successful, rig the fresh copy with `tools/studio/rig_munchie_a.luau`, replace old test model safely, and record photos + QA.
3. **Rojo:** in Windows use the locally installed official CLI and audited Studio plugin. `rojo --version`; `rojo serve default.project.json`, connect only to this Place. If Rojo is not installed, install/configure locally; this GitHub branch alone does not install it. Verify new server/client scripts appear in proper services.
4. **Play test:** 1 player, 2 players, then touch control/mobile emulation. Face Munchie within 7 studs; HIT once = `P0Health=1` + `P0State=Stunned`; HIT after ≥0.55 s = `P0Health=0` + `Launched` + despawn. Test misses, cooldown, behind player, walls, two players landing hits simultaneously, NPC reaches/consumes pizza, and repeated remotes. Check Server Output for errors, FPS and collision floor contact.
5. **Animation assets:** only after rig/new import is correct, use Animation Editor to polish **Idle, Walk, PizzaBite, AttackChef, HitReaction, Knockback, Defeat**, verify marker placements and priorities, publish to Roblox under the intended creator/group (owner permission already granted), capture actual asset IDs; fill `Config.MunchieAnimationIds`. Publishing animations is not publishing the experience. If animation upload fails, mark blocked with exact reason instead of inventing IDs.
6. **Save/verify:** save the authorized Place; test new Play session; capture evidence and real animation IDs. Do not publish experience LIVE or buy ads/activate monetization (not authorized here). Run `python tools/validate_scaffold.py`, `python tools/validate_art_manifest.py`, `git diff --check`. Update manifest/QA/changelog with evidence and merge only once tests pass.
7. **Gameplay status:** this PR covers **one Munchie and a disposable pizza graybox**; it does not implement the P0 complete 30-second wave, 3 routes, door, loss/win/retry, a physical spatula model, chef animation, or camera/game feel. Those remain separate roadmap gates.

## Test ledger (not simulated)

| Check | Status | Evidence |
|---|---|---|
| Repo main `acbdba7` exists | VERIFIED | GitHub commit read |
| Server/input code prepared | CODE ONLY | Feature branch |
| Only approved Place can use Rojo live sync | CONFIGURED NOT TESTED | `servePlaceIds` |
| New palette survives Studio FBX Importer | PENDING | No Studio access in this session |
| NPC moves / first hit / second hit in Studio | PENDING | No Studio access in this session |
| 7 animations published, IDs updated | PENDING | No Roblox account upload in this session |
| Place saved | PENDING | No Studio access in this session |
| Mobile + 2-player gameplay and analytics | PENDING | No Play test yet |

Do not describe this PR as `P0 COMPLETE` until the Play tests and Studio/asset checks above are executed.
