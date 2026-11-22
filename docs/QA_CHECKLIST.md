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

**Nada marcado como pasado todavía:** solo es un checklist planeado.
\n## P0 Munchie en rama `feat/p0-munchie-combat-20261122` — NO TESTEADO\n- [ ] Corroborar PlaceId 122513508386436, backup y conexión Rojo restringida.\n- [ ] Reimportar FBX palette y riggear instancia nueva sin romper la anterior.\n- [ ] HIT x1 pasa a Stunned; HIT x2 a Launched; repetidos, lejanos y detrás son rechazados.\n- [ ] En Play, raíz sin anclar se mueve y knockback no penetra suelo/pared; dos jugadores consistentes.\n- [ ] Pizza pierde una sola porción por mordida y permite interrumpir la mordida.\n- [ ] Animaciones publicadas y asset IDs reales conectados tras polish.\n- [ ] Studio Play/cliente táctil sin errores, métricas solo servidor, capturas guardadas.\n