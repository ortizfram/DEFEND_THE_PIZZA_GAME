# Changelog

## Verificación V0.6 en Studio · 2026-11-22
- Sincronizado Place 122513508386436 con V0.6; guardado versión 12.
- Dos clientes observaron progresión de mordidas y ragdoll; servidor verificó tres impactos por porción, retroceso próximo a 5 studs y física con 11 sockets.
- Limitaciones de medición en COMBAT_TUNING_PVZ_V06.md. Sin cambios al código de producción.


## Validación automática de V0.6 · 2026-11-22
- [GitHub Actions #45040447491](https://github.com/ortizfram/DEFEND_THE_PIZZA_GAME/actions/runs/45040447491): compilación y pruebas de reglas Luau exitosas para commit `d6b1c73`. El QA de ragdoll, escala, 2 clientes y teléfono físico sigue pendiente.


## P0 V0.6 — combate exagerado y tres mordidas, 2026-11-22
- Se incorporó un primer ajuste al código de Pizza Shop: tres mordidas compartidas por porción, ritmo 1 s entre mordidas de cada zombie y daño sincronizado ~0.55 s tras comenzar el clip, visuales intermedios de porción y HUD.
- Espátula con arco de windup/snap/recovery más exagerado, empuje progresivo del primer golpe y segundo golpe con ragdoll físico de Munchie A mediante BallSocket, impulso server-side y TTL de limpieza. Fallback visual cuando el modelo real no está importado.
- Nuevas reglas en Config, `src/server/MunchieRagdoll.luau` y tests puros en `tests/munchie.luau`. Documentación [COMBAT_TUNING_PVZ_V06.md](docs/COMBAT_TUNING_PVZ_V06.md).
- **Este cambio solo está codificado en GitHub; queda pendiente QA en Roblox Studio y móvil físico.** No se cambió ningún Place/pagos/campañas en esta sesión.


## Preparación del playtest P0 · 2026-11-22
- Comprobada correspondencia Studio/GitHub, diez rondas solo alternadas con ráfagas de HIT y respawn.
- Añadidos reporte técnico, hoja anónima para cinco participantes y checklist de teléfono físico.
- Audio 203785492 identificado por metadatos; origen del warning pendiente. Gate humano abierto.


## Pizza Shop · integración Studio · 2026-11-22
- Animaciones del Munchie conectadas al ciclo de combate. HIT móvil separado del salto.
- Verificados derrota, victoria y reinicio en solo, victoria compartida con dos clientes, cierre/reapertura de persiana y entrada táctil emulada. Guardado en versión 11 de Studio. Detalle en `docs/ROADMAP.md`.

## 0.2.0-p0 · 2026-11-22
- Pizza Shop jugable desde el código Rojo: ocho porciones, tres entradas, persiana central, Munchie de dos golpes, espátula, HUD multiplataforma y ronda de 30 s con reinicio.
- QA en Play, cooperativo, móvil físico y conexión de animaciones pendientes.

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

## Locomoción del zombi común V0.7.3, 2026-11-22
- **Caminata sincronizada** a los 5 studs/s (sin tocar la velocidad): `Config.P0.Walk = { Rate = 1.1, Stride = 2.5 }` (velocidad de reproducción y amplitud de zancada, replicados por el servidor y aplicados en `MunchiePlayback`). El pie que apoya retrocedía a ~2 studs/s mientras el cuerpo avanzaba a 5 (patinaba más de la mitad); ahora retrocede a 4,9–5,0 studs/s. Ciclo de ~0,73 s, zancada amplia y torpe (las piernas del Munchie miden 1,15 studs, así que 5 studs/s exige pasos grandes o rápidos).
- **Transiciones**: fundido de 0,15 s entre clips; los clips no cíclicos (PizzaBite, HitReaction) pasan a Idle al terminar en vez de congelarse; el ragdoll continúa desde la pose actual. Medido: salto máximo entre fotogramas 4,8–8,2°, pose congelada máxima 0,019 s, sin chasquido en el primer fotograma de ragdoll.
- **Ritmo de la ronda (sin defender)**: primer zombi llega a la pizza a los 3,9 s y empieza a morder; primera porción cae a 6,5 s; pizza entera comida a los 14,5 s. No se cambió el balance (ver `docs/COMBAT_TUNING_PVZ_V06.md`).

## Combate V0.7.2 — contacto de la pala y zombi común más lento, 2026-11-22
- **Contacto:** además del arco, un zombi recibe el golpe si algún punto del recorrido de la hoja (`Config.P0.Swing[n].Tips`, medidos en Studio) queda a menos de `TouchRadius` = 2,6 studs de su cuerpo. Probado en el motor: zombi a 68° del eje (fuera del arco de 65°) tocado por el side swing → golpeado. Sigue bloqueándolo una pared sólida y el servidor decide el daño.
- **Zombi común:** velocidad de caminata 10 → **5 studs/s** (`Config.P0.MunchieSpeed`, medido 4,95). La animación Walk no se ajustó a la nueva velocidad.

## Combate V0.7.1 — pulido y QA del combo, 2026-11-22
- **Hitbox por arco** (`src/shared/SpatulaHit.luau`, probado en CI): cada swing sólo alcanza zombis dentro de su arco frontal y alcance (overhead ±45°, uppercut ±40°, side ±65°, alcance 8 studs en los tres; ampliados a petición del propietario: el daño no exige tocar con la hoja). Un rayo del servidor (`RespectCanCollide`) impide golpear a través de paredes, postes y la persiana cerrada. Cada swing daña a un zombi como máximo una vez.
- **Remates**: siempre vuelan en sentido contrario a la pizza. Overhead = golpe descendente + rebote bajo; uppercut = vuelo alto (+7 studs); side = lanzamiento lateral con giro. Los miembros del ragdoll ahora colisionan con el suelo (grupo de colisión propio, sin colisión entre piezas).
- **Táctil**: el botón HIT (45 px) quedaba debajo del botón de salto en teléfonos; ahora mide ≥64 px y se coloca a su izquierda.
- Probado en Studio (servidor + 1 cliente, simulador de iPhone 17 Pro y Galaxy A06). **No se probó** con dos clientes reales, toque físico ni mando físico, y los sonidos no pudieron escucharse. Detalle en `docs/COMBAT_TUNING_PVZ_V06.md`.

## Combate V0.7 — combo de espátula en 3 golpes, 2026-11-22
- Secuencia 1 Overhead Slam → 2 Uppercut → 3 Side Swing → 1…; una pausa >1,5 s vuelve al golpe 1. Datos y tiempos configurables en `src/shared/SpatulaSwings.luau` y `Config.P0.Combo/Swing`; reproducción local en `src/client/SwingPlayer.luau` (hombro, codo, muñeca, cintura, cuello, raíz, caderas, rodillas y agarre de la espátula).
- Servidor autoritativo: valida cooldown y orden del combo, y **aplica el daño en el instante del contacto visual** (0,27 / 0,23 / 0,20 s tras el golpe), no al pulsar. Cada swing se resuelve una sola vez. Estela (Trail) en la hoja, whoosh, impacto con chispas y pequeño sacudón de cámara.
- Reacciones por golpe sin cambiar el daño (2 golpes siguen derrotando a Munchie): primer golpe empuja/aplasta, rebota hacia arriba (uppercut) o empuja hacia la izquierda del chef (lateral); el golpe final lanza el ragdoll con tumbo propio (voltereta adelante / mortal atrás / giro lateral). `MunchieRagdoll.launch` ahora da la velocidad exacta a cada pieza (antes el impulso sólo al torso daba ~la mitad).
- Hallazgo: este Studio crea personajes R15 con `AnimationConstraint` (no Motor6D) y esos joints se resuelven en la física, así que la pose se escribe en `PreSimulation`.
- **No se probó** con dos clientes, dispositivo táctil/mando ni a oído (sonidos de archivo stock, provisionales). Detalle en `docs/COMBAT_TUNING_PVZ_V06.md`.

## DTP-3D-003 — Palette texture + 7 animaciones blockout, 2026-11-22
- `munchie_common.apply_palette`: 1 material + `art/source/textures/T_Munchie_Palette.png` (256 px). Los colores viajan dentro del FBX/GLB (verificado al re-importar en Blender). A y B regenerados; renders sin cambios visuales.
- `tools/studio/munchie_animations.luau`: Idle, Walk, PizzaBite, AttackChef, HitReaction, Knockback y Defeat, con markers Footstep/Bite/HitWindow/Despawn, en `ServerStorage.RBX_ANIMSAVES`. Poses clave verificadas en Studio; corregido Defeat, que atravesaba el piso.
- Aprendizaje: la vista previa con `StepAnimations` en modo Edit deja estado en los Motor6D; el rig se restauró (C0/C1 re-resueltos y Motor6D recreados).
- Sin publicar animaciones ni guardar el Place. NPC del servidor pendiente de autorización P0.

## DTP-3D-003 — Import en Studio + rig Motor6D, 2026-11-22
- El propietario importó `Zombie_Munchie_A.fbx` en el Place "Defend The Pizza". Claude verificó por MCP: 21 MeshParts, 3.26 × 4.74 × 3.37 studs (igual que Blender), orientación correcta y 91 % de la altura de un dummy R15.
- El Importer descartó los colores; se restauraron los tokens por pieza en Studio. Se movió el modelo fuera del SpawnLocation.
- Rig rígido construido con `tools/studio/rig_munchie_a.luau` (HRP + Humanoid/Animator, 12 Motor6D, 9 welds) y probado con una pose temporal. El R15 de referencia era temporal y se eliminó.
- **El Place no fue guardado ni publicado por Claude.** Sin animaciones ni lógica de NPC todavía.

## DTP-3D-003 — Variante A aprobada, 2026-11-22
- El propietario eligió **A — Munchie Round**. Rework menor de A (ojos y pupilas +~10 %, boca más ancha, piernas y pies más separados) y regeneración de fuente, renders, comparativa y export FBX/GLB (3364 tris, sin cambios de escala).
- Sin import en Roblox Studio todavía (ninguna instancia conectada); sin rig ni NPC.

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

## Gate de prueba P0 definido — 2026-11-22
- Se inspeccionó GitHub actual: Munchie A aprobado y exportado, Blender A/B, animaciones/rig de Studio, Pizza Shop integrado y pruebas simuladas de solo, 2 jugadores y teléfono emulado ya documentadas.
- Próxima tarea definida: prueba ciega de primera partida con 3–5 jugadores + teléfono físico, medir primer HIT, comprensión del objetivo, claridad de golpe y replay, revisar warning asset 203785492. Siguiente feature solo si pasa: Slice Thief roba una porción.
- Documento: `docs/NEXT_P0_PLAYTEST_GATE.md`. **Planeado; no se realizaron pruebas humanas ni móviles físicas en esta actualización.**
