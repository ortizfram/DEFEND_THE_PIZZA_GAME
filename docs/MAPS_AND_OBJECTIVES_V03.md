# Defend the Pizza! — 3 mapas y objetivos (diseño V0.3)
**Fecha:** 2026-11-21
**Estado:** propuesta; no implementado, no son mapas construidos ni reglas de balance aprobadas.
**Contexto:** GAME_DESIGN.md, COMBAT_AND_REVIVE_V02.md, ROADMAP.md y DECISIONS.md.

## 1. Una regla para todos los mapas
- **Objetivo principal único:** SAVE THE PIZZA! — salvar al menos 1 de las 8 porciones de una pizza enorme al superar las oleadas. Si pierde todas, termina partida. La pizza central y el daño visual nunca desaparecen.
- Zombies caricaturescos llegan por 2–3 entradas; buscan la pizza, pero pueden morder al chef que los intercepta. Más adelante aparecen ladrones que roban una porción y huyen.
- **Dos controles contextuales clave en móvil:** HIT (golpear espátula) y ACT (interactuar cerca de puerta/barrera/botón/compañero caído). PC: click + tecla E; movimiento y salto familiares. ACT cambia rótulo contextual, nunca exige abrir inventario, arrastrar ni apuntar pequeño.
- Compañero caído: ayudar gratis o auto-respawn gratis en ≤10–12 s, como propone COMBAT_AND_REVIVE_V02.md; no observar toda la partida.
- **Una acción especial nueva por mapa** que retrasa la entrada de zombies pero no gana sola la oleada. Las barreras se rompen con golpes, y los efectos tienen cooldown. No crear farmeo infinito de monedas.
- La victoria no exige hacer metas secundarias. Se ofrecen metas opcionales con monedas/reconocimiento limitados por ronda, nunca una tarea forzada que quite tiempo al combate.

## 2. MAPA 1 — PIZZA SHOP (principiante)
**Fantasía:** cocina/pizzería pequeña, luminosa, pizza enorme en mesa central, 2 puertas + 1 ventana. Enemigos se ven por fuera.

Esquema espacial: ventana (norte) → pizza en centro ← puerta izquierda y puerta derecha; jugador inicia al sur. Dos/tres entradas como máximo; en P0 comenzar con una puerta para probar.

- Misión principal: SAVE PIZZA durante **3 oleadas cortas** (hipótesis, probar).
- Acción única: **CLOSE**. Te acercás a puerta/persiana que parpadea y tocás ACT (~1 segundo); se cierra con sonido, cambia físicamente el camino del zombie y aparece candado grande.
- Los zombies golpean la puerta, se agrieta y se rompe. Desde cerca, tocás ACT con etiqueta **FIX** (~2 s) y se arregla gratis luego de pequeño cooldown. Es la misma interacción, no herramienta adicional.
- Meta extra opcional: **CLOSE 2 DOORS** con dos íconos de puerta, recompensa limitada. Si confunde al jugador, quitar objetivo extra y dejar solo CLOSE.
- Momento divertido: se rompe una puerta, entran 5 zombies que salen volando con el golpe; otro compañero cierra una entrada.
- UI: SAVE PIZZA / HIT / CLOSE / FIX / HELP (símbolos visuales asociados).
- Regla de lectura: abierta = zombies entran; cerrada = golpean fuera; rota = entran otra vez. No cerrar permanentemente.

## 3. MAPA 2 — PIZZA STREET (intermedio)
**Fantasía:** calle colorida, pizza gigante en un carrito central, tres callejones, autos de juguete y contenedores grandes.
- Misión principal: SAVE PIZZA durante **4 oleadas cortas** tentativas.
- Acción especial: **PUSH**. Un auto o contenedor alineado con una marca en el piso tiene botón ACT; al tocarlo (~1 s), el auto se mueve solo hasta una posición delimitada y bloquea un callejón. Evitar física difícil de empuje manual, rotación, crafting, inventario.
- Los zombies se juntan y golpean el obstáculo hasta hacerlo salir de su posición. Reutilizable después de cooldown para mantener combate activo.
- Meta extra opcional: **BLOCK 2 PATHS**, representado por dos dibujos de auto delante de callejón. Límite de bonus por oleada.
- Momento divertido: un chef bloquea una horda, otro aprovecha la agrupación para mandar zombies volando; un ladrón podría escapar por una entrada diferente cuando exista.
- UI: SAVE PIZZA / HIT / PUSH / HELP. Abrir camino visual y sonido de auto desplazándose al pulsar. No introducir un sistema de manejo de vehículos.
- Solo: un jugador puede activar el bloqueo y volver a pegar sin quedar atrapado en una tarea de construcción.

## 4. MAPA 3 — PIZZA FACTORY (espectáculo avanzado)
**Fantasía:** fábrica luminosa con pizza gigante, 3 túneles, grandes ventiladores y botones rojos visibles. Las cintas son inicialmente decorativas para no sumar tareas.
- Misión principal: SAVE PIZZA durante **5 oleadas cortas** tentativas.
- Acción especial: **PRESS**. Tocás ACT en botón rojo grande; enciende un ventilador industrial por varios segundos y empuja zombies de una ruta. Después se recarga con indicador visual. No requiere acertijos de interruptores, horarios, mezclas ni múltiples herramientas.
- Meta extra opcional: **USE FAN 2 TIMES** con dos símbolos de ventilador, con recompensa pequeña una vez por ronda.
- Momento divertido: activa ventilador cuando una horda casi llega, los zombies salen volando mientras otro chef defiende última porción. El viento no borra zombies ni anula todas las rutas.
- UI: SAVE PIZZA / HIT / PRESS / HELP. Hélice girando + viento y sonido = funciona; hélice quieta + ícono recarga = esperar.
- Las máquinas no hacen violencia gráfica/gore; empuje caricaturesco y confeti/queso.

## 5. Progresión y viabilidad
- Primera visita comienza en SHOP. Tras completarlo, sugerir NEXT MAP o PLAY AGAIN; STREET y FACTORY pueden desbloquearse en orden solo si playtest confirma que no crea fricción. No obligar 10 partidas repetitivas.
- Los tres mapas comparten pizza de 8 porciones, combate, IA, robar/recuperar (en su gate), enemigos, UI, revive y recompensas. Solo cambia 1 acción de entorno: CLOSE, PUSH, PRESS.
- Adaptar enemigos/número por 1–6 jugadores; no se necesitan varios jugadores para completar objetivos.
- Los mecanismos compran segundos para combatir, **no sustituyen pegarle a los zombies**. Si el jugador solo repara puertas sin luchar, reducir reparaciones.
- Escala de producción: solo **SHOP P0** primero (pizza + una puerta + un zombie + espátula); incorporar ventanas, robos y revive luego; construir Street y Factory únicamente tras superar playtests de diversión del loop principal.
- Tempos 3/4/5 oleadas por mapa son hipótesis de diseño, NO duración aprobada; 20–40 segundos por ola como punto de partida de pruebas.

## 6. Comprensión 3.º–4.º grado: testear, no asumir
- Objetivo visual de 5 segundos: pizza enorme en medio, zombie entra por puerta visible y avanza hacia ella; daño saca porción. Aprender por causa-efecto antes que por tutorial textual.
- Dos acciones de botón fundamentales: HIT y ACT contextual; solo una palabra nueva por mapa: CLOSE, PUSH o PRESS. HELP se usa con compañeros en todos los mapas. Son candidatos de palabras simples **sin nivel lector individual verificado**; probar con usuarios reales.
- Símbolos además de colores, con alto contraste: puerta abierta/rota/cerrada con candado y grietas; bloqueo marcado en carril; ventilador encendido girando; un ícono de mano para ayudar.
- Una alerta prioritaria grande a la vez: pizza en peligro, entrada rota, porción robada o compañero caído; no UI de seis objetivos.
- Recompensas y cuentas no requieren lectura: porciones visibles, corazón de vida, íconos de puerta/coche/ventilador, animación clara.
- Test ciego 3–5 personas sin explicar controles: ¿entienden la misión en 10 s? ¿golpean y accionan primera puerta sin ayuda? ¿ven por qué un cierre protege? ¿repiten? Validar en móvil, uno y dos jugadores, sin asumir conocimientos.

## 7. Analíticas propuestas (NO implementadas)
- DTP_MapStarted (mapId SHOP/STREET/FACTORY; versión y número jugadores); DTP_MapObjectiveUsed (mapId, type CLOSE/FIX/PUSH/PRESS, éxito); DTP_EntryBreached; DTP_MapFinished; DTP_MapReplay; usar DTP_PizzaSliceLost / DTP_PlayerDowned / DTP_TeamReviveCompleted según especificación actual.
- Métricas: primera acción/nuevos joins, primera interacción en cada mapa/participantes, entradas rotas/oleadas, porciones perdidas/ola, mapa terminado/jugadores que empezaron, replay/mapas terminados, segundos downed, D1 y sesión del dashboard cuando existan datos.
- Todas las interacciones deben comprobar distancia/cooldown y estado **en el servidor**; evitar farm/griefing, barreras que bloquean NPC infinitamente, scripts de cliente que otorguen monedas, y conteo de eventos por frame.

## 8. Sin comercializar ni programar todavía
Ideas visuales y mecánicas NO aprobadas individualmente por propietario; no crear assets finales, campañas, compras, Studio ni Place. El siguiente test real es **una pizzería gris con una puerta y un golpe divertido**. No construir tres mapas a ciegas.
