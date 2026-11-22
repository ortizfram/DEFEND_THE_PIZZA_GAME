# QA del juego (antes de declarar cada gate completado)

- [ ] Rojo sincroniza con Baseplate nuevo, sin dañar proyectos anteriores.
- [ ] Server/client arrancan sin errors, antes y después de respawn.
- [ ] Un jugador: primera acción/objetivo sin esperar a nadie.
- [ ] Dos jugadores: enemigo, golpe y estado pizza consistente en ambos clientes.
- [ ] Móvil: botón grande, golpe legible, controles no se superponen.
- [ ] PC: click golpea pero no interfiere con cámara; consola cuando se autorice.
- [ ] Servidor rechaza golpe fuera de rango/velocidad/cooldown y rechaza repetición.
- [ ] Daño a pizza/porción no depende de datos manipulados por clientes.
- [ ] Robar/recuperar no duplica porciones ni premios (Gate 2).
- [ ] Ola/derrota/reintento no se queda atascada; abandono y reconexión.
- [ ] Los funnels y eventos no hacen doble conteo; nada por frame.
- [ ] Latencia/FPS bajo, colisiones, paths NPC, streaming móvil.
- [ ] Comparar con versión anterior, registrar video/capturas reales y bugs abiertos.


## Assets 3D (por asset; ver brief en `art/briefs/`)
- [ ] Fuente `.blend` real + script reproducible; `python tools/validate_art_manifest.py` OK (verifica que existan los archivos declarados).
- [ ] Tris dentro del target interno, 0 non-manifold, pivotes en articulaciones, pies en Z = 0.
- [ ] Export FBX/GLB re-importado sin pérdidas (reporte en `art/qa/`).
- [ ] Import en Studio (Baseplate nuevo) y escala vs dummy R15; orientación, normales y colores correctos.
- [ ] Silueta legible a ~100 px y en cámara móvil real.
- DTP-3D-003 Munchie: los 3 primeros puntos verificados en Blender el 2026-11-22; Studio y móvil pendientes.

La lista conserva requisitos del gate completo. Ver resultados técnicos y pendientes en `P0_REGRESSION_2026_11_22.md` y registrar las sesiones humanas en `P0_PLAYER_OBSERVATION.md`.

## V0.6 — mordidas + swing + ragdoll (QA pendiente)
- [ ] Un zombie muerde 3 veces para quitar UNA porción; el estado 1/3 y 2/3 es visualmente distinguible.
- [ ] Dos zombies comparten el daño de mordidas sobre la porción actual (no 3 cada uno).
- [ ] Un golpe interrumpe mordida antes del instante de daño, sin descontar progreso.
- [ ] 1.er hit empuja hacia atrás gradualmente y mantiene 1 HP, 2.º termina y ragdoll físico de Munchie A.
- [ ] Ragdoll con BallSockets y control servidor, sin efectos raros, sin caer fuera del mapa, cleanup ~2 s.
- [ ] UI/hit móvil no se superpone; 2 clientes ven mismas porciones y cadáver; 30 FPS teléfono físico.
- [ ] Regresión derrota/victoria/retry y warning existente 203785492.
Ver [COMBAT_TUNING_PVZ_V06.md](COMBAT_TUNING_PVZ_V06.md). No marcar CHECK sin Studio/pruebas realmente ejecutadas.
