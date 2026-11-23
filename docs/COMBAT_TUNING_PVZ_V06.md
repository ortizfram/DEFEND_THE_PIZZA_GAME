# P0 V0.6 — Mordidas tipo PvZ, golpe exagerado y ragdoll físico
**Fecha:** 2026-11-22. **Estado:** implementación de código propuesta para probar en Studio, no gameplay confirmado. **Origen:** solicitud del propietario de ajustar impacto y 3 mordidas por porción.

## Referencia externa: Plants vs. Zombies original
- El **Sunflower común** tiene aproximadamente **300 HP**.
- El zombie común come con un ritmo de daño de aproximadamente **100 HP/segundo**, por lo que destruye la planta en **~3 segundos** (con un zombie).
- **Precisión importante:** el dato es una tasa de daño por tiempo; PvZ NO exige universalmente «3 animaciones de mordida» individuales. Nuestra traducción a 3 mordidas visibles es una **decisión propia** para Roblox y comprensión de jugadores de 3.º–4.º grado.
- Fuentes consultadas 2026-11-22: [Sunflower (PvZ) — wiki.gg](https://plantsvszombies.wiki.gg/wiki/Sunflower_(PvZ)); [Damage — wiki.gg](https://plantsvszombies.wiki.gg/wiki/Damage); [I, Zombie Endless strategies — wiki.gg](https://plantsvszombies.wiki.gg/wiki/I%2C_Zombie_Endless/Strategies).

## Contrato jugable nuevo
1. **Pizza = 8 porciones** como siempre; los zombies llegan a la porción todavía presente, no a un girasol real.
2. **Cada porción resiste 3 mordidas**, acumuladas **entre todos los zombies** presentes. Un solo zombie inicia una nueva animación PizzaBite cada **1 s**; el impacto se registra a los **0.55 s** de comenzar la animación, para que morder y quitar vida visual se correspondan. Si recibe un golpe que interrumpe ese wind-up, **la mordida pendiente se cancela**.
3. Visual: 0 golpes = porción completa; 1 = más tostada y ligeramente transparente; 2 = muy dañada y notablemente transparente; 3 = desaparece y comienza otra porción. HUD muestra `BITE 1/3` y `BITE 2/3` como apoyo textual; el juego debe leerse también sin texto.
4. **Golpe básico = 1 HP**. Munchie tiene **2 HP**: al primer hit aturde y es empujado **~5 studs** gradualmente (no teleport instantáneo); al segundo se convierte en un **ragdoll real** y el impulso lo lanza **más lejos**, con componente ascendente. Dos golpes sigue siendo suficiente.
5. **Ragdoll:** rig Motor6D original de Munchie A, BallSocketConstraint para juntas de cuello/brazos/piernas y Root unido al HumanoidRootPart, server network ownership, cuerpo/cabeza collision simple; no simular 21 piezas colisionando unas contra otras. Lo destruimos tras ~2 s (Debris). El cliente deja de sobrescribir poses si atributo `Ragdolled`.
6. **Sin rig importado:** placeholder gris mantiene vuelo visual mediante Tween, **pero NO es ragdoll físico**. Reportarlo como limitación al probar.
7. **Golpe exagerado:** anticipación de espátula a 85° y latigazo hasta -105° en ~0.1 s, recuperación elástica ~0.2 s. Son valores de prueba; no equivale a animación de avatar publicada. Con servidor autoritativo, el efecto puede sentirse tardío con lag: evaluar necesidad de anticipación visual **local sin daño client-side** tras QA.
8. Config central `src/shared/Config.luau`: BitesPerSlice=3, BiteIntervalSeconds=1.0, BiteHitDelaySeconds=0.55, FirstHitPushSpeed=24 studs/s, FinalRagdollHorizontalSpeed=62 studs/s, FinalRagdollUpSpeed=25 studs/s y RagdollLifetimeSeconds=2.0. **Son velocidades de lanzamiento / parámetros, NO metros garantizados de vuelo**; calibrar en Studio. En `src/server/Munchie.luau` permanecen los objetivos declarativos de push 5 y vuelo 20, con físicas finales no determinísticas.

## Protocolo de QA — no afirmar completado hasta verlo
- [ ] **Compilación Luau** y pruebas de reglas puras: 3 impactos acumulan una porción, dos impactos no, segundo zombie puede aportar a misma porción, no sumar por encima de 3, Munchie cae a 2 golpes.
- [ ] **Roblox Studio**, 1 zombie come 3 veces: el 1.er impacto no elimina porción; el 2.º tampoco; el 3.º reduce 8→7. Ataques repetidos no cuentan dos veces por frame.
- [ ] **Dos zombies simultáneos**: la misma porción puede quedar destruida después de 3 mordidas combinadas; el progreso por porción no se reinicia porque cambió atacante.
- [ ] **Interrumpir el mordisco antes de 0.55 s**: primer golpe cancela bite pendiente; no se pierde progreso.
- [ ] **Primer golpe**: se ve aturdimiento, retroceso visible de ~5 studs y no atraviesa geometría crítica (si atraviesa: cambiar a barrido raycast o fuerzas controladas).
- [ ] **Segundo golpe**, con rig real: verificar motores desactivados excepto Root, 11 BallSocket, cuerpo suelto con gravedad, vuelo más lejos que antes, no glitch de partes que se separan o atraviesan el piso.
- [ ] **Sin rig**, placeholder: vuelo visual de respaldo; indicar claramente que no es ragdoll.
- [ ] **2 clientes**: todos ven las mismas porciones/rig/ragdoll. No hits falsos desde explotador, spam respetando cooldown. Capturar logs y diferencias entre server/clients.
- [ ] **30 FPS / teléfono físico**: rendimiento con ~5 ragdolls en pantalla, posibilidad de disminuir TTL/constraint count; no superponer HIT con salto.
- [ ] Resolver o registrar warning de audio/asset 203785492 si continúa; no atribuirlo a los cambios sin evidencia.
- [ ] Playtest ciego de 3–5 jugadores: primer hit, entendimiento de progresión en mordidas, satisfacción segundo impacto, ¿replay?, sin un tutorial largo.

## Aceptación
**GO:** los jugadores distinguen claramente mordida 1/2/3 y el segundo golpe lanza a Munchie con física cómica consistente, sin caída de FPS ni errores críticos. **REWORK:** ragdoll pesa demasiado, se desarma, atraviesa pared/pizza, el ritmo es confuso o el swing tapa la cámara.
**No hacemos aún:** Slice Thief, zombies que dañan chefs, monedas/tienda, loadout, otros mapas, productos Robux, publicación.

## Estado de sincronización
Código versionado en GitHub no equivale a que Roblox Studio haya ejecutado este nuevo código; se debe conectar Rojo, guardar un respaldo del Place y verificar test. El cambio no autoriza publicar la experiencia.

## Evidencia técnica del commit inicial (2026-11-22)
- GitHub Actions **COMPLETED / SUCCESS**, run [45040447491](https://github.com/ortizfram/DEFEND_THE_PIZZA_GAME/actions/runs/45040447491), SHA `d6b1c730e84cf4984e8005e6a555cd67fc8959cc`. El workflow compiló Luau de `src/` y `tests/`, ejecutó las pruebas de `tests/munchie.luau` y validó la estructura de repositorio/manifest. Esto prueba sintaxis y reglas puras **NO** vuelo/ragdoll/UX en Roblox Studio.
- **Siguiente verificación manual:** ejecutar con el Place correcto y rig Munchie A; solo si el ragdoll es físicamente estable, el golpe es satisfactorio y la mordida llega a 3/3 cerrar el gate.

## Verificación en Studio · 22/11/2026
- Place 122513508386436 ejecutaba 0.2.0-p0. Se respaldó mediante guardado (versión 11), sincronizó V0.6 desde GitHub y guardó la edición final en versión 12.
- Prueba temporal con servidor y dos clientes de Studio, rig Munchie A real. Servidor observó 8/0 → 8/1 → 8/2 → 7/0 (porciones/mordidas), seguido de acumulación en otra porción.
- Dos primeros golpes produjeron desplazamientos observados de 5.74 y 4.84 studs antes del segundo impacto; estas muestras incluyen movimiento entre frames.
- Dos ragdolls: 11 sockets, 11 motores deshabilitados, 0 piezas ancladas y propiedad de red del servidor. Velocidades medidas tras lanzamiento de aproximadamente 40 y 44 studs/s horizontales y 13 ascendentes. Ambos clientes observaron un ragdoll y progresión replicada de porciones.
- Las muestras de clientes omitieron estados intermedios por frecuencia de observación; no constituyen prueba de sincronización frame a frame. Distancia total de vuelo, estabilidad durante todo el TTL, interrupción del wind-up y valoración visual humana siguen pendientes.
- Sin corrección del código de producción: el desfase verificado era la versión instalada en Studio. Scripts de prueba temporales retirados y Play finalizado. Sintaxis de scripts ejecutados validada por Studio; CI previo documentado arriba.

## V0.7 · combo de espátula en 3 golpes (22/11/2026)
Place 122513508386436: respaldo previo = versión 12; guardado final = **versión 16**. Config `0.3.0-three-swing-combo`.

**Probado en Studio (Play, servidor + 1 cliente, personaje R15 real):**
- Trayectorias distintas: punta de la hoja (studs, relativo al chef) en ventana/impacto/seguimiento — Overhead (2.5,3.7,3.1)→(1.2,-1.3,-4.5)→(1.4,-2.2,-4.2); Uppercut (1.3,-2.8,-1.4)→(0.9,0.6,-4.3)→(1.6,5.1,0.1); Side (0.9,0.3,5.2)→(-0.5,0.2,-5.0)→(-4.0,0.3,-1.6). Capturas con pose retenida y en vivo (estela incluida) revisadas.
- Brazos y torso se mueven: cintura 32°/24°/42°, hombro hasta 168°/115°/88°, agachada de raíz −0,42 en los dos primeros.
- Daño en el contacto: el HP cambia 0,22–0,31 s tras pulsar (= impacto configurado + 20–40 ms de red). Cada swing = 1 cambio de HP, sin duplicados; 12 disparos crudos al remoto en ~1,1 s → 2 swings aceptados.
- Combo 1→2→3→1 y reinicio tras pausa de 1,7 s (eco `1,1`). Dos golpes derrotan a Munchie en los tres estilos (kills observados: overhead, uppercut; side-kill sólo en un caso mezclado, ver abajo).
- Ragdoll (21 piezas, extremidades ≤3,0 studs del torso, sin separaciones): overhead voló 28,9 studs, tumbo ≈250°; uppercut 20,5 studs con **+7,2 de altura** y ≈400°; otro overhead hacia la pizza sólo 9,5 (choca con la escena). Primer golpe: uppercut empuja 6,4 studs rectos con hop +2,2; side empuja 5,4 studs (4,6 hacia la izquierda del chef).
- Mecánicas previas: HUD `BITE n/3`, 8 porciones, rondas de 30 s con reinicio y `Pizza eaten!`, sin errores de script en consola (sólo el warning previo de audio 203785492).

**No probado / pendiente:** dos clientes (sincronía de swings ajenos), táctil y mando reales (el botón HIT/CAS no cambió), persiana/puerta durante el nuevo swing, victoria `Pizza saved!`, side-swing como golpe final (sólo cubierto como primer golpe), sonido a oído: **whoosh = `action_jump.mp3` y impacto = `impact_explosion_03.mp3` recortado son marcadores de posición**. Limitación heredada: la regla "zombi más cercano" puede golpear a uno pegado o detrás del chef.

## V0.7.1 · pulido y QA del combo (22/11/2026)
Place 122513508386436: respaldo previo = versión 16; guardado final = **versión 19**. Parámetros en `Config.P0.Swing`.

**Hitbox:** de espaldas = 0 impactos; con pared sólida entre chef y zombi = 0; de frente despejado = 1. Arcos/alcances y selección cubiertos por CI.

**Remates como segundo golpe** (misma zombi, servidor + cliente, 21 piezas conectadas, miembros ≤3,1 studs del torso):
| Golpe | Vuelo | Dirección | Altura máx. |
|---|---|---|---|
| Overhead (tras side) | 18,7–22,7 studs | 18,7–22,6 **lejos de la pizza**, 0,4 lateral | +0,7 a +1,1 (golpe al suelo y rebote) |
| Uppercut (tras overhead) | 18,4–18,8 studs | 13,8–16,0 lejos de la pizza | **+7,2** |
| Side (tras uppercut) | 25,9–27,7 studs | **23,9–26,4 a la izquierda del chef**, 6,9–9,9 lejos de la pizza | +0,8 |
Reposo en el suelo: superficie visible más baja −0,04 studs en tres caídas con orientaciones distintas (la métrica por cajas daba 0,5 y era un artefacto).

**Clientes y controles:** F, R2 de mando (evento sintético) y clic de ratón → swings aceptados en orden 1,2,3. Simulador táctil: `TouchEnabled`, botón HIT existe; antes se solapaba con el salto (toque que caía en el salto), ahora 70 px sin solape en iPhone 17 Pro (750×381) y Galaxy A06 (705×338). Ruta de observador (swing de otro personaje) verificada sobre un clon. **Pendiente:** dos clientes reales, toque físico/`SendTouchEvent` (requiere capacidad no disponible), mando físico, y escucha humana del audio (whoosh a +10–14 ms del tiempo configurado, impacto recortado a 0,5/0,9 s, ambos reproduciéndose).

## V0.7.3 · locomoción y ritmo de ronda (22/11/2026)
Place 122513508386436: respaldo previo = versión 21. Un cliente (el segundo no se probó, a petición del propietario).

**Ritmo medido, ronda de 30 s sin defensa (servidor):** zombi 1 aparece a 0 s y llega a la pizza a **3,9 s** (empieza a morder al llegar); zombis 2–5 aparecen a 3,0 / 6,1 / 9,0 / 12,0 s y llegan a 6,9 / 9,9 / 13,0 s; porciones perdidas a 6,5 / 8,5 / 9,6 / 10,5 / 11,6 / 12,6 / 13,6 / 14,5 s. Las tres mordidas por porción siguen funcionando (HUD `BITE 1/3`, 2,6 s entre la llegada y la primera porción). Un defensor tiene ~3,9 s de caminata más 2,6 s de mordidas antes de perder la primera porción y cada zombi exige 2 golpes (~0,8 s): con un solo defensor la ronda parece **fácil**; ritmo de aproximación no es demasiado lento.

**Si se quiere más presión (no aplicado):** intervalo de aparición (hoy 3 s, fijo en `Bootstrap.server.luau`), `Config.P0.MunchieSpeed` (5), `BiteIntervalSeconds` (1,0) y `BiteHitDelaySeconds` (0,55). Subir la velocidad a 6–6,5 o bajar el intervalo de aparición a 2–2,5 s sería lo primero a probar; si se cambia la velocidad, reajustar `Walk.Rate` (≈ velocidad/5).

## V0.8 · Slice Thief (22/11/2026)
Place 122513508386436: respaldo previo = versión 23. Un cliente; sin segundo jugador (se acordó que no hace falta).

**Probado en Studio (Play, servidor + 1 cliente):** (con el ladrón adelantado a 4 s sólo para la prueba y restaurado a 9–12 s después)
- **Robo y escape (chef sin defender):** aparece, llega a la pizza a los 2,3 s de correr, `Slices 8→7`, `Carried=1`, porción visible en sus manos; escapa 2,1 s después: `StolenLost=1`, `Carried=0` y las porciones **no se descuentan otra vez** (después sólo Munchie: 6→0; 1 perdida + 7 comidas = 8).
- **Golpe y recuperación:** golpe 1 → `Slices 7→8` exactamente +1, `Carried=0`, la porción vuela de vuelta y desaparece de sus manos; el ladrón queda con 1 HP y sigue huyendo sin ella. Golpe 2 → muerto con ragdoll (21 piezas), `StolenLost=0`. Munchie sigue comiendo sobre el resto sin errores.
- **Ronda terminando con el ladrón huyendo:** ladrón roba (2→1) y Munchie se come la última a los 0,4 s: `Pizza eaten!`, `Carried=0`, sin modelo de porción robada ni ladrones sobrantes; la ronda siguiente empieza con 8 porciones, `Carried 0`, `StolenLost 0`. Caso extra encontrado y corregido: si el ladrón roba la **última** porción, la ronda seguía hasta los 30 s; ahora termina cuando escapa con ella (16,07 s en la prueba).
- **Aparición natural:** 10,1 s y 10,6 s; un solo ladrón; 9,0 studs/s frente a 5 de Munchie; roba a los 12,4–13,0 s.
- **Compatibilidad:** swings 1 y 2 (arco/contacto) golpean al ladrón; ragdoll de 21 piezas; mordidas de Munchie y la velocidad de Munchie (5) y su intervalo de aparición (3 s) sin cambios.

**No probado / pendiente:** dos jugadores simultáneos sobre el mismo ladrón (la doble recuperación/pérdida está cubierta por los tests de `SliceLedger` en CI, no en Studio con dos clientes); swing 3 sobre el ladrón; el aspecto visual es provisional (capturas parciales); con el chef defendiendo, el balance de 2 HP/9 studs/s no se afinó.

## V0.8.1 - Thief: porción sobre el sombrero (22/11/2026)
Place 122513508386436: respaldo previo = versión 27; guardado = **versión 31**. Un cliente.
**Probado en Studio:** pose afinada sobre un clon vivo del rig (manos a 0,01-0,19 bajo el borde de la porción, palmas 0,5-0,7 arriba; capturas frontal y lateral). Ladrón real: robo con `CarryAt`, porción hija del ladrón con 3 soldaduras al `ThiefCap`; porción rígida sobre el sombrero durante la carrera (0,00 de variación) y giros suaves (máx. 18,6 grados/fotograma); manos arriba mientras lleva la porción y de -0,25 a -1,46 (brazos abajo) ~0,5 s después del golpe. Escape (robo 6,3 s, escape 8,5 s): sin ladrón ni porción huérfana, `Carried=0`. Recuperación: 7->8 exacto, `Carried=0`, porción desoldada; segundo golpe: derrotado con ragdoll de 21 piezas, `StolenLost=0`.
**No probado:** dos clientes (no se puede lanzar un segundo cliente desde el entorno de pruebas); la cámara real de juego sólo dejó una captura parcial (el ladrón entraba por el borde). Brazos del Munchie cortos: las manos quedan 0,1-0,2 bajo el borde de la porción (con la cabeza grande no alcanzan más arriba sin deformar el rig).

## V0.9 - vida del chef, DOWNED y revive gratis (22/11/2026)
Place 122513508386436: respaldo previo = versión 31; guardado = **versión 33**. Un cliente real.
**Probado en Studio:**
- **3 mordidas -> DOWNED** (chef real delante de un Munchie): corazones 3->2->1->0 a 0,5 / 2,3 / 4,1 s (1,8 s entre mordidas); caído: `Downed`, cartel HELP, prompt REVIVE, `PlatformStand`; un swing mientras está caído no se acepta (0 swings).
- **Temporizador gratuito:** chef NPC caído a los 2,1 s de la ronda, de pie a **12,03 s** (misma ronda, hearts 3). Con el chef real caído en una ronda sin defensa, el reinicio de ronda (la pizza se acaba a los ~14,5 s) lo levanta antes: comportamiento esperado.
- **Revive real:** el jugador real mantiene el `ProximityPrompt` sobre un chef NPC caído: soltar a 1,0 s no revive; mantenerlo revive a los **2,02 s**, hearts 3, prompt y cartel eliminados. Casos negativos: un caído no revive, uno mismo no, a 80 studs no, y el segundo revive es no-op (primero `true`, segundo `false`).
- **Regresión:** ronda con el chef aparcado idéntica a antes (primera porción a 6,5 s, luego 8,5/9,5/10,5...); 3 corazones intactos; velocidades (Munchie 5, ladrón 9) y aparición del ladrón 9-12 s sin cambios; swings, ragdoll y recuperación de porción siguen en CI/pruebas previas.
- **Táctil (simulador iPhone 17 Pro 750x381):** los 3 corazones (x 327-423, y 50-78) no se solapan con la barra, HIT, salto ni joystick.
**No probado / honesto:** **dos clientes reales** (no se puede lanzar un segundo cliente desde el entorno): el revive se probó con el jugador real sobre un chef NPC registrado mediante un gancho de pruebas que sólo existe en Studio (`DTP_ChefTest`); el caído real no puede usar su propio prompt (la UI lo desactiva en el cliente y el servidor lo rechaza). Toque físico y mando físico sin probar. Sensación/diversión de la mordida y de las cifras (3 corazones, 2 s, 12 s) son hipótesis a playtestear.

## V0.9.1 - pulido Thief y validación (22/11/2026)
Respaldo previo = versión 33. **Probado (un cliente):** manos/porción numéricamente alineadas; contorno `CarryGlow` presente al cargar; cámara por defecto emulada (sólo prueba) muestra al ladrón con la porción; Config de Studio restaurada (ladrón 9 studs/s, aparición 9-12 s); sin objetos temporales. Mediciones previas: aparición 10,1 y 10,6 s desde el inicio real de ronda; robo ~12,4-13,0 s (distintos).
**PENDIENTE / NO completado:** todas las pruebas con **dos clientes reales** (mismo ladrón visto por ambos, recuperación única, golpes simultáneos sin duplicar, corazones independientes, revive por otro jugador, soltar antes de 2 s, sincronía HUD). No se puede lanzar un segundo cliente desde este entorno; requieren Test > Local Server con 2 jugadores.

## QA regresión Thief (22/11/2026, un cliente)
Sin cambios de código ni de Place (v35 intacta). Rondas reales sin defender: aparición del ladrón a 9,05 / 9,20 / 11,30 / 11,50 / 11,90 s (dentro de 9-12 s); robo 2,3-2,6 s después (11,4-14,1 s). Contorno `CarryGlow` y `CarryAt` aparecen sólo en el instante del robo; al escapar: `Lost=1`, ladrón destruido, sin restos; cada ronda nueva arranca con 8 porciones, `Carried=0`, `Lost=0`.
**No verificado:** golpe al ladrón con porción (suelta, baja brazos, contorno desaparece, recuperación única): 3 intentos automatizados con swings enviados por el cliente no conectaron (el ladrón escapó); no es prueba de fallo del juego, sólo de mi método. **Dos clientes: no ejecutado** (una sola instancia controlable). Ver `docs/PLAYTEST_CHECKLIST.md`.

## V1.0 - partida de 3 oleadas (22/11/2026)
Place 122513508386436: respaldo previo = versión 35; guardado = ver informe final. Un cliente; las porciones/ladrón se ejercitaron con el gancho Studio-only `DTP_WaveTest` (autojugador que ejecuta `resolveImpact`, el mismo camino de golpe legítimo del botón HIT).
**Probado:** 5 partidas.
- Secuencia 1->2->3 con transiciones de ~2 s y oleadas de 20,0 s; ladrón sólo en W2 y W3 (aparece 10,4-10,9 s tras iniciar la oleada, dentro de 9-12 s); nunca en W1.
- Ladrón con porción (golpe legítimo): robo (Slices 7->6, Carried 1, contorno y CarryAt activos) -> primer golpe 0,11 s después: Slices 6->7 **una sola vez**, Carried 0, contorno y CarryAt desaparecen, Hp 1; segundo golpe lo derrota. Un solo `DTP_SliceRecovered`.
- Escape en W2 (ignorado a propósito): Lost=1, Slices 8->7, el ladrón y su contorno desaparecen; W3 arranca con 7 y la victoria final se da con 7 porciones (`Pizza saved!`).
- Derrota anticipada sin defender: 8->4 al pasar W1->W2 (conservadas), 0 en W2 -> `Pizza eaten!` inmediato.
- Reinicio: 4 s después vuelve a Wave 1 con 8 porciones, Carried 0, Lost 0. HUD verificado en captura (`WAVE 1/3 DEFEND - PIZZA 8/8 - 17s`).
**Balance observado (autojugador, NO humano):** el autojugador defiende casi perfecto; no dice nada sobre dificultad real. Sin defensa la pizza se acaba en ~15-30 s.
**No probado:** dos clientes reales (pendiente); la espera por una porción en disputa al terminar una oleada está revisada en código pero no se produjo en las pruebas (los ladrones se resolvían antes de los 20 s); sensación/dificultad con humanos. Aviso 203785492 sigue en consola (sin impacto).

## V1.0.1 - revisión pre-playtest (23/11/2026)
Un cliente, sin humanos. Probado: partida completa W1->W2->W3->`Pizza saved!` (8 porciones, autojugador), chef con 3 mordidas -> DOWNED (HELP + prompt REVIVE) -> de pie solo a los 12,0 s con 3 corazones; reinicio limpio (Wave 1, 8/8, Lost 0, hearts 3, 1 Munchie nuevo, 0 ladrones, 0 contornos, 0 porciones cargadas huérfanas). Daño conservado y regresión del ladrón: ver V1.0.
**Primeros 10 s (cámara normal, captura):** los Munchies verdes y la pizza se leen bien, corazones y porciones legibles. Observaciones SIN cambiar: la pizza es pequeña frente al arena (no "gigante") y el chef a veces la tapa; en PC no había pista del golpe -> añadida.

## V1.1 - pizza central 1,6x (23/11/2026)
Respaldo previo = versión 39. **Tamaño:** radio 4 -> 6,4 studs (x1,6). **Probado (un cliente, autojugador Studio-only):** 8 porciones; Munchie se detiene a >=7,56 del centro (pivote; borde 6,4), no entra en la pizza; mordidas 8/0 8/1 8/2 7/0 (3 por porción); ladrón roba al borde (8->7), la porción transportada mide 4,6 de largo (igual que antes), recuperación 3->4 una sola vez (contorno y brazos se apagan), escape Lost=1 (8->7); victoria (`Pizza saved!`), derrota (`Pizza eaten!` en W2) y reinicio a Wave 1 con 8/8.
**NO verificado visualmente:** el visor 3D de Studio devolvió negro en todas las capturas (también en modo Edit, antes de cualquier Play): problema del entorno, no del juego (sin NaN/partes gigantes). Falta mirar a ojo con la cámara normal: que la pizza se vea como centro, que el chef no la tape, que el HUD no estorbe. Si hay un problema de encuadre, el ajuste mínimo sería mover la posición de inicio del chef.

### V1.1 - corrección (23/11/2026): visor operativo, escala final 1,8x
El visor 3D volvió a funcionar. Captura con cámara normal: a 1,6x la pizza se leía pero a 18 studs ocupaba poco ancho y el chef tapaba su parte baja; se subió a **1,8x** (radio 7,2; `StealDistance` 7,4). Con 1,8x: pizza claramente mayor, queso y pepperoni visibles, Munchies y HUD distinguibles; el chef sigue tapando parte baja de la pizza mientras está justo delante (se despeja al moverse; no se cambió la posición de inicio).
Probado a 1,8x: Munchie se detiene a >=8,36 del centro (borde 7,2); 8 porciones al inicio y tras reinicio; derrota W1 y reinicio; ladrón roba (8->7), porción de 4,6 de largo (sin cambio), recuperación 7->8 una vez con contorno y brazos apagados; escape L=1 (8->7) y pasa a W3 con 7; victoria `Pizza saved!`. Mordidas 3/porción probadas a 1,6x (misma lógica). CI de b43d500 falló por un error en mi prueba (paso esperado 0,35, no 0,25) -> corregido en cc973f4.

## V1.2 - cinco mordiscos por porción (23/11/2026)
Respaldo previo = versión 41. Probado en Studio (un cliente): secuencias del servidor 8/0->8/1->...->8/4->7/0 (exactamente 5 mordiscos por porción); varios Munchies cerca comparten progreso (hasta 5 cerca, 1 mordisco cada ~0,5 s en conjunto); largo del queso medido 7,20 / 6,05 / 4,90 / 3,74 / 2,59 (factor inicial 0,8, luego ajustado a 0,96 para dejar un resto pequeño a 4/5) y pepperoni oculto a 4/5, coincidiendo con el progreso del servidor; captura real con `BITE 2/5` y la porción visiblemente recortada. 3 oleadas, 8 porciones al inicio, ladrón (robo 7->6, recuperación 6->7 una vez; la porción robada es entera aunque tuviera mordiscos), conservación de mordiscos entre oleadas (S=7 B=4), victoria, derrota y reinicio OK.
**No probado explícitamente:** la cancelación de una mordida al golpear al zombi (lógica sin cambios; bajo defensa automática los mordiscos no se acumulaban); dos clientes.
