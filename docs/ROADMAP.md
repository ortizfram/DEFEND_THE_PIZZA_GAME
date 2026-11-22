# Roadmap de implementación (propuesto, no ejecutado)

## Gate 0: repo + empaque — estado: REPO GITHUB SINCRONIZADO
- [x] Estructura versionada de scripts, reglas de IA, documentación y configuración.
- [x] Repositorio remoto GitHub creado y contenido inicial subido/verificado (2026-11-21).
- [ ] Cambiar visibilidad a **privada** en GitHub Settings si el propietario así lo requiere: el repo se encontró PÚBLICO.
- [ ] Miniatura principal storyboard aprobada visualmente.
- [ ] Competidores directos y evidencia de mercado archivados.

## Gate 1: P0 graybox — prueba de integración completada en Studio
- [ ] Baseplate NUEVO / Place verificado y respaldado.
- [ ] Rojo y Claude Code conectados/validados con permiso del propietario.
- [x] Una cocina gris + pizza con 8 porciones que cambian visualmente.
- [x] 3 entradas de enemigos, 1 Munchie, trayectoria simple a la pizza.
- [ ] Espátula con hitbox en arco generoso, daño y knockback validado servidor, feedback instantáneo cliente.
- [x] 1 oleada de 30 s y perder/ganar/retry; controles móvil/PC.
- [ ] Propuesta V0.2: zombie común puede morder a chef que lo intercepta, con sistema básico de vida/caída y respawn gratis; probar diversión antes de ampliar IA.
- [ ] Analytics FTUE y core registrados por servidor (local debug/producción según disponibilidad).
- [ ] QA 1 jugador, 2 jugadores, móvil, red lenta, respawn.
- [ ] Test: golpear es divertido incluso sin monedas ni colección.

> Implementado en `src/` el 22/11: arena, ocho porciones, tres entradas, persiana, IA de aproximación y mordida a la pizza, espátula, HUD, ronda y reinicio. Las casillas funcionales se cierran tras QA en Studio.

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

## Setup de Windows / primer Zombie Munchie
- [x] Checklist y prompt de setup [SETUP_WINDOWS_FIRST_MUNCHIE.md](SETUP_WINDOWS_FIRST_MUNCHIE.md) (Blender/Studio/Git/VS Code, Claude Code y Rojo opcionales por etapa).
- [ ] Confirmar herramientas instaladas en la PC del usuario; clonar el remoto de este repo.
- [x] Modelar A/B y comparar siluetas. Variante A elegida.
- [x] Exportar e importar A, construir rig y siete secuencias de animación de prueba.
- [ ] Verificar la integración de animaciones y lectura en dispositivo móvil.

## PRIORIDAD ACTUAL: prueba P0 a ciegas antes de más contenido
- [x] Guía ejecutable del hito: [NEXT_P0_PLAYTEST_GATE.md](NEXT_P0_PLAYTEST_GATE.md).
- [ ] Probar en teléfono físico real (no simulador) y en 2 clientes, registrar FPS/error y lectura de HIT/ACT.
- [ ] Probar a ciegas con 3–5 jugadores nuevos: primer HIT ≤10 s, comprensión pizza/porciones, deseo de replay y errores críticos.
- [ ] Localizar aviso de asset 203785492 con tipo incompatible, sin asumir origen.
- [ ] Ajustar únicamente errores de experiencia/hit/retroceso/primer minuto, volver a probar.
- [ ] Si pasa gate, siguiente feature: un ladrón roba porción y huye; un golpe la recupera. No añadir tienda/lobby/mapas antes.

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

## Prueba de integración en Studio · 22/11/2026
- Solo, con cliente automatizado: derrota con 0 porciones, victoria con 8 y reinicio con 8.
- Servidor y dos clientes simulados: ambos cargaron HUD, atacaron, observaron movimiento de articulaciones y recibieron victoria. El servidor verificó el cierre y reapertura de la persiana.
- Simulador iPhone 17 Pro horizontal: separadas las áreas de HIT y salto, ataque táctil validado en servidor. Pendientes dispositivo físico, red lenta y valoración de jugadores humanos.
- Se reprodujeron poses del rig importado en partida. Consola: aviso de recurso 203785492 con tipo incompatible; origen sin identificar. Place 122513508386436, versión de edición 11.

## Preparación del playtest · revisión técnica adicional
Diez rondas automatizadas solo completadas el 22/11/2026: cinco derrotas y cinco victorias, con reinicios y ráfagas de HIT. Respawn conserva espátula, HUD y acción HIT. Detalle en [P0_REGRESSION_2026_11_22.md](P0_REGRESSION_2026_11_22.md). Hoja de observación y checklist física en [P0_PLAYER_OBSERVATION.md](P0_PLAYER_OBSERVATION.md). Gate humano y teléfono físico pendientes. Recurso 203785492 identificado como audio Pop Close Sound; solicitante pendiente.
