# Siguiente hito: P0 blind playtest y pulido de combate — 2026-11-22

**Estado:** plan operativo para probar el P0 existente. **No implementa funciones nuevas ni modifica Roblox Studio.**

## Situación real verificada en el repo
- Munchie **A — Round** fue aprobado por propietario; Blender .blend A/B, FBX/GLB A, palette, rig Motor6D, siete blockouts de animación, pruebas y screenshots de Studio están versionados.
- Pizza Shop P0 tiene ocho porciones, tres entradas, persiana central, espátula de dos golpes para Munchie, HUD, 30 segundos de ronda, derrota/victoria/retry.
- Según ROADMAP y CHANGELOG del 22/11, pruebas de Studio simuladas: solo pierde con 0 porciones, gana con 8 y reinicia; servidor con dos clientes compartió victoria; simulador de iPhone separa HIT de salto. **No equivale a prueba en teléfono físico ni con jugadores nuevos.**
- Consola registró aviso sobre asset **203785492 de tipo incompatible**; origen no identificado.
- El manifest de Munchie sigue **IN_PROGRESS**: no subir a QA_PASS sin prueba física y comprobación de asset.
- La conexión y el guardado Studio actual deberán verificarse *de nuevo* antes de tocar el Place; no asumir estado de la instancia por estas notas.

## Objetivo de este hito (no la próxima tienda ni otro mapa)
Responder: «¿En 10 segundos un niño sin instrucciones entiende SAVE THE PIZZA, golpea al zombie y se divierte haciendo que salga volando?». Si no, no expandir contenido.

### A. Preparar una build de prueba controlada
1. Revisar `git status -sb`, `origin/main`, `AGENTS.md`, `docs/ROADMAP.md` y sincronizar sin fuerza ni reset.
2. Abrir Place **Defend The Pizza**, confirmar PlaceId y versión, crear copia de seguridad o duplicado de prueba; no modificar otras experiencias ni publicar cambios nuevos sin autorización.
3. Verificar que la integración Rojo ↔ Studio coincide con la rama actual y que el Munchie A con rig/colores/animations se instancia correctamente.
4. Revisar alerta de recurso `203785492` en consola y aislar origen, sin inventar cuál asset es.
5. Hacer 10 rondas automáticas o manuales de regresión, solo/2 clientes, alternando HIT rápido/repetido, persiana y derrota/retry. Una vez que eso pasa, invitar personas.

### B. Test sin explicar nada (3–5 jugadores, con permiso apropiado)
**Pruebas separadas:** al menos 1 jugador solo PC, 1 en **teléfono físico**, 1 sesión cooperativa de 2 jugadores. Intentar usuarios que desconozcan el prototipo; observación presencial o grabación con permiso, sin recolectar datos personales/menores sin consentimiento.

1. Presentar gameplay directamente, **sin decirles cuál botón usar**. Registrar si identifican pizza como objetivo.
2. Cronometrar desde control disponible al **primer HIT válido**; objetivo exploratorio ≤10 s.
3. Registrar si identifican cómo se pierden las 8 porciones, entienden el botón de HIT y se dan cuenta de la persiana sin leer un tutorial.
4. Preguntar después, no durante: «¿Qué intentabas hacer?», «¿Qué momento fue más divertido?», «¿Querés jugar de nuevo?»; no sugerir la respuesta.
5. Medir por sesión: tiempo hasta primer hit, 1.º/2.º zombie derrotado, porciones al final, primer cierre útil, primer retry, golpes que se sintieron injustos, muertes/bugs, FPS en dispositivo cuando se pueda medir.

### C. Gate de aceptación — objetivos orientativos, no estadísticas reales
- **Todos (ideal ≥4/5)** entienden que hay que salvar pizza sin instrucciones verbales.
- **Al menos 4/5** consiguen un golpe válido en ≤10 s de tomar control.
- **Al menos 3/5** identifican qué pasó cuando desapareció una porción.
- **Al menos 3/5** eligen replay voluntariamente al terminar, o expresan que repetirían por un momento concreto. Medir, no forzar.
- **0 fallos críticos**: bloqueo permanente, cliente sin HIT, datos/pizza inconsistentes entre clientes, desync, animaciones incapacitadas, crashes, sobreposición con jump móvil.
- **Controlabilidad:** golpe visible cuando conecta, 2 hits coherentes para Munchie, hitbox no castiga un toque razonable, mobile physical playable.
- Con una muestra pequeña estos ratios son señales de UX, **no pruebas estadísticas de retención D1**.

### D. Qué arreglar si el test falla
- Si no entienden objetivo: agrandar pizza, resaltar mordida y triángulo que desaparece; animar primer zombie hacia pizza.
- Si falla primer HIT: mejorar tamaño/posición de botón y swing/hitbox, no agregar tutorial largo.
- Si no sienten el golpe: aumentar lectura de cara, squash y knockback del 2.º hit; sonido PLAK/boing original o permitido; sincronizar marker y daño autoritativo.
- Si no usan persiana: guiño visual/ACT contextual, no objetivo obligatorio con cinco líneas.
- Si no repiten: corregir presión/ritmo/feedback y retry rápido antes de coins, dailies, lobby, nuevos enemigos o ads.

## Siguiente feature SOLO si supera gate
**Slice Thief vertical slice**: un solo ladrón robando una porción de la pizza y escapando; el chef golpea para recuperarla. Mantener lo demás igual. Eso prueba la diferenciación y genera momentos compartibles. Más adelante daño al chef, rescate gratis y economía según gates. No activar revive pago.

## Entrega esperada de Claude/Codex
- Checklist con pruebas **ejecutadas** y entorno (PC, simulador vs teléfono real, solo/co-op).
- Capturas/video reales si existen y permiso; logs de bugs, errores de consola y 3 correcciones priorizadas.
- Una tabla de sesiones anónimas con tiempos y acciones, **sin inventar usuarios ni métricas**.
- Solamente arreglos mínimos para pasar gate, con test de regresión.
- Actualizar docs/ROADMAP.md, docs/QA_CHECKLIST.md, CHANGELOG.md, analytics spec si corresponde y manifest de assets según prueba.
- Commit/push a remoto verificado, con hash. Si no puede probar un móvil real, registrar `PENDIENTE TEST FÍSICO`, no simularlo.

**Regla:** no crear PIZZA STREET, FACTORY, tiendas, música final, dailies ni UGC Marketplace hasta que la física del golpe y el P0 sean divertidos en test a ciegas.
