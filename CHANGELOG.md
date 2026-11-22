# Changelog

## 0.1.0-preproduction — 2026-11-21
- Preparación de repositorio separado para Defend the Pizza! con estructura Rojo, scripts bootstrap sin gameplay, configuración, reglas de IA, documentación y comprobación de estructura.
- 2026-11-21: Se añadió `docs/SYNC_POLICY.md`, un script PowerShell seguro de check/pull/push y reglas explícitas para IAs.
- 2026-11-21: Se sincronizó el scaffold inicial con `ortizfram/DEFEND_THE_PIZZA_GAME` conservando el commit original del repositorio remoto. El repo se encontró **público**; cambiar visibilidad en GitHub Settings si se requiere privado.
- No se ha probado Roblox Studio, conectado un Place ni implementado jugabilidad.

## Monetización propuesta — 2026-11-21
- Se documentó catálogo cosmético hipotético, precios tentativos, presentación dentro de sesión, etapas G0–G5, seguridad de pases y recibos, métricas y condiciones de activación.
- Cambios exclusivamente documentales. **No se creó ningún producto Roblox, game pass, Developer Product, ID real, tienda funcional ni monetización activa.**

## Combate y rescate propuestos V0.2 — 2026-11-21
- Se evaluó la sugerencia de zombies atacando también a chefs: defensa de pizza, downed, rescate de compañero gratis y respawn gratis rápido. Revive instantáneo por Developer Product quedó como hipótesis G4+ que puede descartarse por pay-to-win.
- Documento [docs/COMBAT_AND_REVIVE_V02.md](docs/COMBAT_AND_REVIVE_V02.md). Solo cambios documentales; sin scripts nuevos, Place conectado ni monetización activada.

## Tres mapas y objetivos simples V0.3 — 2026-11-21
- Diseño de Pizza Shop (CLOSE puertas), Pizza Street (PUSH bloqueos), Pizza Factory (PRESS ventilador) y objetivos secundarios opcionales fáciles de leer. Misma misión central de salvar pizza y misma mecánica HIT + ACT contextual.
- Documento fuente `docs/MAPS_AND_OBJECTIVES_V03.md` y enlaces desde GAME_DESIGN, ROADMAP, DECISIONS y ANALYTICS_SPEC. No se crearon mapas reales, scripts, assets ni compras.

## Experiencia completa V0.4 — 2026-11-21
- Diseño textual de loading real, lobby y PLAY, tienda y 3 slots de loadout cosmético, HUD móvil, resultados, cutscenes cortas.
- Balance inicial: 1/2/2/5/12 golpes ligeros por Runner/Munchie/Thief/Tank/Boss opcional; slap/charged, reacción cómica, locomoción y animaciones con markers, cheats/antifarming server-side.
- Economía Coins/XP, tres daily quests fáciles, reset UTC/guardado seguro, bandas de recompensa, dirección musical original, SFX por contacto y settings de accesibilidad.
- Documentos `PLAYER_JOURNEY_UI_V04.md`, `COMBAT_PHYSICS_ANIMATION_V04.md`, `REWARDS_DAILY_AUDIO_V04.md` + vínculos a decisiones, roadmap y analytics. **Solo documentación; no implementado en Studio ni productos creados.**

## DTP-3D-003 Zombie Munchie — blockouts A/B, 2026-11-22
- Primeros archivos 3D reales: `art/source/Zombie_Munchie_A.blend` (Round) y `Zombie_Munchie_B.blend` (Noodle), generados con Blender 5.2.3 LTS por scripts propios y sin add-ons (`tools/asset_generation/`, `run_all.ps1`).
- Renders frontales e isométricos de ambos, lineup con proxies (chef, Runner, Big Eater, pizza), silueta a ~100 px y game-cam móvil 844×390 en `art/renders/munchie/`.
- Export candidato de A: `art/export/Zombie_Munchie_A.fbx` + `.glb`, re-importados en Blender sin pérdidas (`art/qa/Zombie_Munchie_A_export_qa.json`).
- Brief, evaluación, recomendación A y propuesta de rig/animaciones en `art/briefs/DTP-3D-003_Zombie_Munchie.md`. Manifest DTP-3D-003 → `IN_PROGRESS`; el validador ahora falla si un asset declara archivos inexistentes.
- **No probado en Roblox Studio** (sin instancia conectada). Sin rig, animaciones, NPC ni publicación.

## Arte, UI, UGC y assets con IA — Diseño V0.5, 2026-11-22
- Art Bible Toy Pizza Panic; paleta y tokens JSON, plan de assets con estados PLANNED, plantilla de brief por asset y prompts GPT/Claude Code para archivos reales, import y QA.
- Guía reutilizable creada y sincronizada en el Roblox Vault. Separación explícita entre accesorios cosméticos internos y UGC Marketplace con derechos/costos/validación.
- Preparación de validador estático del manifest y tokens. **No se generaron .blend/.fbx finales, no se conectó Studio, no se publicó UGC ni se activó tienda.**

## Instalación Windows y primera criatura — 2026-11-22
- Se añadió `docs/SETUP_WINDOWS_FIRST_MUNCHIE.md` con descargas oficiales, comandos seguros, prompts y dos variantes de Zombie Munchie, propuesta A Round / B Noodle. Claude y Blender no fueron controlados remotamente; ninguna malla real o animación se generó por documentar este proceso.
