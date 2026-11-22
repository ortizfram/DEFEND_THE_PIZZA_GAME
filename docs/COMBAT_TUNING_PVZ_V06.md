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
