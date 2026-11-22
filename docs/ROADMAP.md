# Roadmap de implementación (propuesto, no ejecutado)

## Gate 0: repo + empaque — estado: REPO GITHUB SINCRONIZADO
- [x] Estructura versionada de scripts, reglas de IA, documentación y configuración.
- [x] Repositorio remoto GitHub creado y contenido inicial subido/verificado (2026-11-21).
- [ ] Cambiar visibilidad a **privada** en GitHub Settings si el propietario así lo requiere: el repo se encontró PÚBLICO.
- [ ] Miniatura principal storyboard aprobada visualmente.
- [ ] Competidores directos y evidencia de mercado archivados.

## Gate 1: P0 graybox — estado: NO IMPLEMENTADO
- [ ] Baseplate NUEVO / Place verificado y respaldado.
- [ ] Rojo y Claude Code conectados/validados con permiso del propietario.
- [ ] Una cocina gris + pizza con 8 porciones que cambian visualmente.
- [ ] 3 entradas de enemigos, 1 Munchie, trayectoria simple a la pizza.
- [ ] Espátula con hitbox en arco generoso, daño y knockback validado servidor, feedback instantáneo cliente.
- [ ] 1 oleada de 30 s y perder/ganar/retry; controles móvil/PC.
- [ ] Propuesta V0.2: zombie común puede morder a chef que lo intercepta, con sistema básico de vida/caída y respawn gratis; probar diversión antes de ampliar IA.
- [ ] Analytics FTUE y core registrados por servidor (local debug/producción según disponibilidad).
- [ ] QA 1 jugador, 2 jugadores, móvil, red lenta, respawn.
- [ ] Test: golpear es divertido incluso sin monedas ni colección.

## Tres mapas propuestos — construcción secuencial
- [x] Diseño conceptual de 3 mapas con una acción local cada uno: [MAPS_AND_OBJECTIVES_V03.md](MAPS_AND_OBJECTIVES_V03.md).
- [ ] Gate 1/P0 únicamente PIZZA SHOP con una puerta, zombie y espátula; medir comprensión y diversión antes de expandir.
- [ ] Luego completar PIZZA SHOP (puertas/ventanas CLOSE y FIX), probar con 3–5 jugadores sin tutorial.
- [ ] Solo si Shop funciona, hacer PIZZA STREET (PUSH bloqueos de callejón).
- [ ] Solo después, PIZZA FACTORY (PRESS botón para ventilador de empuje).
- [ ] QA solo/móvil, autoritativo servidor, visual no solo por color, analítica por mapa y objetivo.

## Experiencia completa V0.4 — planificación, NO implementado
- [x] Diseño de pantallas: [PLAYER_JOURNEY_UI_V04.md](PLAYER_JOURNEY_UI_V04.md) — Loading real, PLAY, lobby, Loadout, Shop, Daily, HUD y cutscenes ≤3 s.
- [x] Diseño de combate: [COMBAT_PHYSICS_ANIMATION_V04.md](COMBAT_PHYSICS_ANIMATION_V04.md) — zombie común 2 golpes, runner 1, thief 2, tanque 5, jefe opcional 12; slap/charged opcional, knockback cómico y animaciones.
- [x] Diseño de recompensas: [REWARDS_DAILY_AUDIO_V04.md](REWARDS_DAILY_AUDIO_V04.md) — Coins, Chef XP, 3 quests diarias accesibles, sonidos y música original/licenciada.
- [ ] P0: SOLO golpe básico, zombie común, pizza, una puerta y feedback; sin moneda persistente, loadout, quests, shop ni cinemáticas complejas.
- [ ] Tras P0 divertido: UI loading mínima, Play directo y score simple de oleada; QA móvil/solo.
- [ ] Tras rescate/robos probados: RewardsService + ProfileStore guardado robusto, luego 3 dailies y loadout de skins gratis.
- [ ] Lobby estético, mapas adicionales y música de variedad solo cuando no perjudican rendimiento y tiempo al primer HIT.
- [ ] Monetización de Robux se mantiene bloqueada hasta autorización explícita y QA de recibos.

## Dirección artística profesional V0.5 — diseño, NO assets implementados
- [x] Art Bible de Toy Pizza Panic, tokens de color/UI, briefs/prompts IA, manifest y política UGC/licencias documentados: [ART_DIRECTION_AI_ASSETS_V05.md](ART_DIRECTION_AI_ASSETS_V05.md).
- [ ] Seleccionar/validar en tamaño móvil silueta de pizza, espátula y Zombie Munchie (2 golpes); generar fuentes editables y QA de import con Studio autorizado.
- [ ] P0 usar Parts/mallas básicas y un botón HIT; no crear lobby detallado, 3 mapas o accesorios globales antes de gameplay.
- [ ] Validar componentes UI en phone/tablet/desktop, safe area y gamepad; al aprobar, agregar SHOP/LOADOUT/DAILY.
- [ ] UGC global Marketplace únicamente después de cumplir reglas técnicas, elegibilidad/costos, revisión de derechos y autorización explícita.

## Gate 2: diferenciación — estado: NO IMPLEMENTADO
- [ ] Ladrón Thief roba una porción y huye; recuperación servidor una sola vez.
- [ ] Propuesta V0.2: rescatar compañero caído gratis con interacción cercana y clara en móvil.
- [ ] Rutas de escape, animaciones legibles, clipping / latencia QA.
- [ ] 1 upgrade simple; probar primer clip natural en 2 jugadores.

## Gate 3: MVP con contenido — estado: NO IMPLEMENTADO
- [ ] 5 olas, escalado 1–6 jugadores, dificultad para solo, quick retry.
- [ ] 3 tipos de enemigos SOLO si agregan decisiones distintas.
- [ ] Playtest a ciegas 3–5 personas: comprensión, primer golpe, primer premio, momento divertido, replay.
- [ ] Analytics completitud/replay y métricas nativas D1/sesión cuando exista data real.

## Monetización: diseño separado del lanzamiento
- [x] Catálogo y etapas de monetización **planificados**, sin productos reales: [MONETIZATION_PLAN_V1.md](MONETIZATION_PLAN_V1.md).
- [ ] G1–G2: **sin ventas**; validar diversión, robo y rescate.
- [ ] G3: tienda cosmética en modo visual/gratuito + pruebas de retención.
- [ ] G4a: solo con autorización, piloto Game Passes Crazy Chef y Golden Spatula.
- [ ] G4b: después de QA/retención/conversión, evaluar Developer Product de celebración tras victoria con recibos idempotentes.
- [ ] G5: Supporter y cosméticos de temporada según evidencia, no fechas obligatorias.
- [ ] Opcional G4+ previa autorización: evaluar revive instantáneo pago **sin bloquear rescate/respawn gratis**; ver [COMBAT_AND_REVIVE_V02.md](COMBAT_AND_REVIVE_V02.md).

## Gate 4: acabado y lanzamiento — estado: NO AUTORIZADO
- [ ] Arte, audio, menús, rendimiento y persistencia si realmente aportan.
- [ ] Monetización responsable solo con aprobación expresa y validación de receipts.
- [ ] Pruebas, documentación real de builds, revisión del propietario.
- [ ] Publicación y Ads solo mediante autorización expresa posterior.
