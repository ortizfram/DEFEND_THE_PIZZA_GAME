# Rewards, Daily Goals, Music & SFX — V0.4
**Fecha:** 2026-11-21
**ESTADO:** DISEÑO PROPUESTO, sin DataStore/tienda/audio implementado, sin cifras de retención/ventas reales.
**Documentos relacionados:** PLAYER_JOURNEY_UI_V04.md, COMBAT_PHYSICS_ANIMATION_V04.md, MONETIZATION_PLAN_V1.md, MAPS_AND_OBJECTIVES_V03.md.

## 1. Economía que recompensa jugar, no AFK
**Dos monedas/referencias simples para el jugador:** 
- **COINS (monedas de pizza)**: gratuitas; gastarlas solo en cosméticos de la tienda COINS. No comprar reanimaciones ni reparar pizza con Robux; no vender paquetes de coins en MVP. No crear dos monedas blandas.
- **CHEF XP + LEVEL**: progreso visual persistente; nivel desbloquea gorros, insignias y poses, pero **no** mejora daño/velocidad/vida permanente.
- **Mejoras entre oleadas (solo dentro de la partida)**: recompensas de juego sencillas, sin pago: por ejemplo un ligero empuje extra temporal, ayuda visual, una curación de chef gratuita cuando se balancee. Si se añade mejora de fuerza/duración, debe ser accesible por igual a todos los participantes, no en GamePass/Robux.
- El jugador no pierde coins/XP al fallar una ronda; obtiene menos recompensa de completar, no una penalización. Si el equipo gana, todos reciben la misma base; no robar recompensas del último golpe.

## 2. Tabla de recompensas iniciales (HYPOTHESIS, no está balanceada)
**Por sesión completada, ejemplo por jugador:**

| Acción | Recompensa inicial | Frecuencia y antiexploit |
|---|---:|---|
| Terminar una oleada | 10 Coins + 20 XP | Una vez por jugador/ola validada en servidor |
| Ganar Pizza Shop | 50 Coins + 40 XP | Una vez por matchId y jugador, se puede volver a jugar |
| Ganar Pizza Street | 70 Coins + 50 XP | Igual, si mapa habilitado |
| Ganar Pizza Factory | 90 Coins + 60 XP | Igual, si mapa habilitado |
| Derrotar zombie | 0 Coins individuales | Evitar last-hit farming; mostrar **+score** no persistente para feedback |
| Bloquear/defender con puerta/auto/fan | +5 SCORE visual, 0 Coins extra por repetición | Contador por mapa, sin farming de acciones contextuales |
| Recuperar porción robada | +10 SCORE visual al equipo | La recuperación es premio emocional; evita spam de crear ladrones |
| Perder partida | Coins/XP de oleadas completadas | Sin promesa de bonus de victoria, sin penalización a saldo |
| Completar misión diaria | +60 a +120 Coins | Solo una vez por questId/dayId, servidor y DataStore |

**Ejemplo concreto:** Pizza Shop con 3 oleadas: `30 Coins por olas + 50 por victoria = **80 Coins** y `100 XP. Es un supuesto sujeto a duración real y a observación de repetición. El puntaje visual de kills no abre farm infinito.

**Tienda COINS propuesta:** gorro rojo 120 Coins (≈2 Shop victorias), delantal de queso 220 (≈3), espátula de chispas 350 (≈5), victoria "Pizza Flip" 450 (≈6). Son números iniciales; no vincular precios de Robux a estos cosméticos sin revisar la economía.
**Progresión de nivel:** nivel 1→2: 100 XP, 2→3: 150 XP, 3→4: 200 XP, luego +50 XP por nivel. Puede ajustar pacing, no incrementar HP del chef ni daño a zombies con niveles.
**Recompensas de hit:** flash de estrella, sonido y score flotante; no entregar Coins por cada hit para evitar spam/abuso. El daño lo autoriza servidor.

## 3. Objetivos diarios: tres tarjetas, tres tipos, solo acciones reales
**Regla:** mostrar máximo **3 misiones activas al día**. Selección y progreso en servidor según mapas realmente disponibles y si se puede jugar solo. Misiones simples de una línea en inglés Grade 3–4, con iconos. Las palabras deben validarse con usuarios reales; nivel escolar no certificado de manera individual.

### Catálogo inicial de quests

| ID | Texto visible | Condición validada servidor | Recompensa |
|---|---|---|---:|
| DAILY_ZOMBIES_10 | HIT 10 ZOMBIES | 10 zombies distintos golpeados (no 10 taps al mismo) | 70 Coins |
| DAILY_WAVES_2 | WIN 2 WAVES | Finalizar 2 oleadas | 70 Coins |
| DAILY_PLAY_1 | PLAY 1 GAME | Participar y terminar partida válida (no AFK) | 60 Coins |
| DAILY_DOORS_2 | CLOSE 2 DOORS | Dos cierres útiles y distintos, solo si Shop disponible | 60 Coins |
| DAILY_SAVE_SLICE | SAVE 1 SLICE | Recuperar 1 porción de Thief, solo si desbloqueado | 90 Coins |
| DAILY_PUSH_2 | PUSH 2 CARS | Bloquear 2 entradas diferentes, solo si Street habilitado | 70 Coins |
| DAILY_FAN_2 | USE FAN 2 TIMES | Activar 2 ventilaciones reales, solo si Factory habilitado | 70 Coins |
| DAILY_RESCUE_1 | HELP 1 FRIEND | Rescate real de downed ally, SOLO con amigos y alternativa compatible en solo | 80 Coins |
| DAILY_WIN_MAP | WIN 1 MAP | Completar un mapa compatible con perfil | 100 Coins |

**Selección propuesta:** una meta básica de combate, una misión de mapa accesible y una misión de completar/jugar. Si solo hay Shop, nunca asignar Pizzeria Factory. Si el usuario juega solo, no asignar HELP FRIEND a menos que se ofrezca un objetivo alternativo real y seguro, por ejemplo WIN 1 WAVE. Evitar generar más quests de las que pueden cumplirse en una sesión corta; no exigir jugar más de 10 minutos para una recompensa diaria.
**Reclamo:** automáticamente marcar completada y mostrar botón CLAIM en Daily/Lobby. Reclamar es voluntario y no bloquea Play. Si se quiere entrega automática para evitar confusión, tomar una decisión de UX única durante pruebas; no otorgar dos veces.
**Sin rachas diarias (streaks) al principio** para no crear presión FOMO. Una marca de “Daily Done!” y pequeño check basta.

## 4. Reset, guardado e idempotencia
- **Día de juego**: fecha UTC en servidor, por ejemplo `2026-11-21` (no basado en hora del cliente); al primer login tras 00:00 UTC elegir 3 objetivos del pool aplicable. UI muestra "NEW GOALS TOMORROW" o contador real, con fecha de UTC clara en docs/telemetría.
- **Persistencia**: perfil en DataStore con `schemaVersion`, `coins`, `chefXP`, `level` derivable, `ownedCosmetics`, `equipped`, `daily={dayId,quests,progress,claimed}`. No guardar cada golpe: acumular en memoria y guardar por puntos seguros (fin de ronda, leave, shutdown) bajo límites Roblox; `UpdateAsync` y protección contra doble sesión/overwrite.
- **Antifarming:** servidor confirma hits, cierre de puerta y resultados; cada zombie/puerta/ola/match tiene ID de servidor único por sesión. No confiar en el cliente con contadores y no premiar AFK solo por estar conectado.
- **Transacciones:** comprobar falta de duplicación de rewards en reconexión y múltiples servidores. Cada daily se marca claimed en operación única y no se entregan Coins dos veces; fallos de DataStore deben reintentarse y no declarar granted si no hubo persistencia duradera.
- **Privacidad:** no registrar datos personales en custom event props. Manejar guardado fallido con mensaje corto y sin falsas promesas de Coins.
- **Daily completo** no debe requerir Robux, invitar amigos ni hacer compras. Modo solo siempre viable.

## 5. Música — propuesta de dirección original, no canciones existentes

| Momento | Estilo musical ORIGINAL | Tempo guía | Función |
|---|---|---:|---|
| Loading | Casi silencio + campana de pizzería | N/A | No cansar durante carga |
| Lobby | Funk cartoon / bajo elástico / pizzicato juguetón | `100 BPM | Optimista, leve, loop suave |
| Pizza Shop | Percusión slapstick + bajo rítmico alegre | `122 BPM | Acción clara sin estrés excesivo |
| Pizza Street | Beat de percusión y trompetas cómicas | `132 BPM | Más energía sin tapar SFX |
| Pizza Factory | Electro-cartoon + percusión de máquina | `140 BPM | Espectáculo y ritmo |
| Big Eater / jefe | Percusión pesada y metales cómicos | `150 BPM | Aviso emocionante, no terror |
| Victory | Fanfarria propia muy corta con nota final brillante | `2 s | Recompensa |
| Defeat | Trombón descendente cómico | `1 s | Humor, no castigo |

**No reproducir ni copiar canciones de franquicias o tracks sin licencia.** Producir música original con permisos claros o seleccionar assets válidos de Roblox Creator Store y guardar asset IDs/licencias/autor. No asumir que un audio externo de YouTube se puede copiar. Dos capas de música opcionales (base/capas de presión) que se cruzan con `TweenService` / mezcladores; no reproducir todas simultáneamente.
**Música no define gameplay:** señales visuales completas para personas con audio silenciado. Volumen Music y SFX por separado, mute opcional y reducción de intensidad; evitar sobresaltos auditivos.

## 6. SFX diseñados para ser inmediatamente legibles
- **Spatula swing fallido**: whoosh pequeño; **Hit**: PLAK + boing corto; **Heavy hit**: WHOMP profundo con resorte; **Combo 3**: campanita divertida.
- **Zombie hit**: grunt cómico "UH!" corto, cara de sorpresa; **Zombie flung**: swoosh/boing de personaje volador, no scream fuerte.
- **Pizza bite**: nom-nom exagerado + desaparece triángulo; **Thief steals**: alarma corta de `0.5 s que se reproduce solo al primer robo, no cada frame; **Slice recovered**: ding y vuelo de queso.
- **Door close**: CLANG metálico suave + candado visible; **Door break**: CRACK y polvo; **Car push**: "scrape + thunk"; **Fan button**: "beep + whoosh wind"; **Fan ready**: click corto.
- **Chef downed**: trompeta floja + icono HELP; **Friend revive**: pop de botella de soda + confeti pequeño; **Auto-respawn**: twinkle corto.
- **XP/Coins**: 1 ding por paquete recibido en fin de ola, no 10 sonidos simultáneos; **Daily claim**: pequeña cascada musical; **Shop preview**: audio sólo si usuario pulsó PREVIEW.
- **Mix**: música baja durante hits/alertas, no doblar boings por cada cliente al mismo tiempo; limitar SFX simultáneos por tipo/distancia y usar sonido 3D para ubicación de enemigos cuando se pueda.
- **Assets de prueba**: IDs sólo tras verificar permisos y formato; no inventar SoundIds. Evitar audio demasiado fuerte o saturado, probar móvil/auriculares/PC.

## 7. Cutscenes y sonido sincronizado
La secuencia exacta de cámaras/Skip está en PLAYER_JOURNEY_UI_V04.md. Todas duran `0.5–3 segundos, son salteables y se apoyan en SFX originales; no largas escenas antes del primer HIT. Usar Animation Event Markers para apoyar SFX de pasos/impactos, pero validación lógica de hits, compras, daño y recompensas sigue siendo del servidor.

## 8. Métricas (NO implementadas)
- Misiones: `DTP_DailyGenerated`, `DTP_DailyProgress`, `DTP_DailyClaimed` y `DTP_DailyRewardFailed`; contar jugadores únicos que vieron/cumplieron/reclamaron, segmentar por questId/versión sin registrar el valor en cada golpe.
- Rewards: `DTP_CoinsEarned`, `DTP_CosmeticUnlocked`, `DTP_LevelUp` agregados por partida, no por frame; primera recompensa/joins; monedas gastadas / obtenidas por ventana; valor de inventario.
- Audio/UI: first-time Play button usage, loadout opened, shop opened; duración carga, fallos de guardado y errores de sonido (logs QA), no telemetría sensible.
- Retención: comparar D1/D7 y replay antes/después de agregar Daily; detectar si los objetivos distraen de salvar pizza o premian AFK.
- **Criterio de prueba:** jugadores completan misión sin preguntar qué hacer; pueden jugar igual cuando no la reclaman; ninguna recompensa duplica aunque cambien de servidor.

## 9. Orden de implementación
**P0**: solo feedback de hit, porciones visuales, partida corta y mensaje de victoria/derrota. **P1**: un contador de Coins/XP por ronda con guardado probado (sin tienda) y música/SFX mínimos autorizados. **P2**: 3 misiones diarias simples al tener loop estable y datos persistentes fiables. **P3**: tienda de Coins, loadout y más pistas musicales, cinemáticas cortas y variedad de enemigos. **P4**: monetización Robux exclusivamente por autorización separada y QA de receipts. 
