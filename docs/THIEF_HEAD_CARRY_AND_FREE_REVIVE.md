# Bloques siguientes — Slice Thief sobre sombrero + ataques a chefs y rescate gratis
**Fecha:** 2026-11-22. **Estado:** brief de implementación solicitado; **NO implementado en Studio** al registrar este documento.
**Place único:** 122513508386436. Último reporte humano: v27. Confirmar Place y versión actual antes de escribir.
**Fuente:** `src/server/Bootstrap.server.luau` (makeCarried/holdSlice/spawnThief/stealSlice/onThiefHit), `src/client/MunchiePlayback.luau` (clips y Motor6D), `src/server/SliceLedger.luau`, `docs/COMBAT_AND_REVIVE_V02.md`.

## Bloque 1 — Nueva silueta y animación «pizza sobre sombrero»
El ladrón **NO debe cargar la pizza delante del pecho**. Mientras tiene una porción robada, debe mostrar:
- Gran porción de queso/pepperoni **horizontal o ligeramente inclinada ENCIMA de su sombrero oscuro**, no dentro de la cabeza ni tapando su cara. Evitar que flote separada del sombrero. Centrar sobre ThiefCap/Head; conservar tamaño legible en cámara de juego.
- **Ambos brazos levantados**, codos flexionados y palmas **por debajo de los lados de la porción**. Los dos brazos aparentan sostenerla: nada de manos a la altura del pecho o atravesando la pizza.
- Mientras huye a 9 studs/s, piernas siguen corriendo y los brazos mantienen la pose de sostén, con un **balanceo leve** de cuerpo/pizza pero sin clipping ni soltarse en giros. Usar la rig/animación existente; dar prioridad únicamente a pose de brazos durante `carried`, no recrear Walk ni el modelo.
- Al robar: subir brazos + porción a la posición, evitar aparición instantánea en el pecho. Al recibir golpe: soltar de inmediato, brazos vuelven a pose normal, pieza recuperada vuelve al pizza board con la animación ya existente. Al escapar: limpiar portador y objeto sin clones huérfanos. Al morir/reinicio/round finish: liberar pose y objeto.
- Tomar como referencia el sombrero real (`ThiefCap` está soldado a `Head`) para `CFrame`/attachment; el `holdSlice` existente sigue el pivot del modelo con `CFrame.new(0,0.1,-1.6)`, responsable de la carga frontal. Reemplazar sólo esa transformación y agregar una capa de pose/estado `CarryingSlice` para brazos, replicada a clientes. Si opta por Weld en vez de PivotTo, cuidar el retorno de `flySlice`, colisiones, masa, limpieza y red.
- Tras recuperar la porción y huir sin ella, la animación de brazos vuelve a Walk; no quedar congelado ni continuar alzándolos.
- **Sin alterar** SliceLedger: 8 máximo, robo -1, recuperación +1 exactamente una vez, escape sin segundo -1, una aparición por ronda. Mantener speeds de Thief 9 y Munchie 5, spawn 9–12 s.

**QA necesario de Bloque 1:** video/capturas reales desde vista de juego, vista frontal y lateral; brazos tocando visualmente porción por encima de cap tanto al correr como al girar; uno y dos clientes con ladrón/porción sincronizados; golpe con slice deja pose normal; escape y reinicio sin porción flotante; ninguna pérdida/duplicación de slice, 3 mordidas de Munchie intactas. No afirmar «listo» con screenshot de pose estática únicamente.

## Bloque 2 — Primer contraataque Munchie + DOWNED + REVIVE GRATIS
Proceder **después de que el bloque 1 pase su QA**, o registrar bloqueo y terminar. Sigue la propuesta del archivo `docs/COMBAT_AND_REVIVE_V02.md`, simplificada:
1. **Munchie común** busca la pizza como ahora. Si el chef se interpone/está muy cerca, telegrafía una mordida de contraataque breve, vuelve al rumbo pizza sin perseguir al chef permanentemente. Validación, rango, cooldown, invulnerabilidad tras daño y vida únicamente server-side. `AttackChef` ya existe como blockout; reutilizarlo si funciona, sin pedir assets nuevos.
2. Chef con **3 corazones visibles** (estado server-authoritative). Mordida de Munchie quita 1; feedback claro, ~1 s de invulnerabilidad provisoria para no quitar tres en un instante. Si se necesita retocar balance, parametrizar, no cambiar arbitrariamente la velocidad del zombie.
3. Con 0 corazones, chef pasa a **DOWNED**: no puede atacar, aparece un indicativo HELP legible; sin morir ni volverse espectador permanente por mecanismos de Roblox. Mantener la pizza como única condición de derrota de ronda.
4. Otro chef cerca puede mantener **REVIVE ~2 s** con una interacción contextual usable en PC/móvil/mando. Verificar distancia/tiempo/estado en servidor, sin exploits ni duplicados. Reaparece o se levanta con corazones recuperados e invulnerabilidad breve.
5. Si nadie ayuda, incluso en modo solo **respawn gratuito en ≤10–12 s**, medido desde caída, sin bloqueos que duren toda la ronda; no vender revive, sin Developer Products ni prompts de compra.
6. El Thief mantiene su comportamiento de robo/escape; su contraataque al chef **no forma parte de este bloque**.
7. QA mínimo: 1 cliente recibe 3 mordidas separadas y cae, vuelve gratis en ≤12 s; 2 clientes, uno cae y el otro lo revive sosteniendo 2 s; otro jugador no revive de lejos ni dos veces; la pizza continúa perdiéndose normalmente, no se generan hearts inconsistentes tras reset/reinicio/respawn; controles móviles emulados sin superposición, marcar prueba física separada.

## Restricciones de costo/créditos y de edición
- Seguir `AGENTS.md`, `docs/WORK_CREDIT_EFFICIENCY.md` y `docs/SYNC_POLICY.md`. Una **sola sesión, dos bloques secuenciales** solicitados explícitamente. No leer/reconstruir todo el repo; tocar sólo Bootstrap, playback y 1–2 módulos/HUD/tests necesarios.
- Comprobar **Place único 122513508386436**, backup seguro, cambios del remoto, sincronización Rojo/MCP antes de editar; no crear otro Place. No publicar juego, animaciones/UGC, anuncios ni compras sin permiso.
- Completar bloque 1, QA y guardar. Seguir bloque 2 si la infraestructura/permiso lo permite sin reconstrucción grande; si requiere mucho más trabajo, **registrar PARCIAL y no consumir créditos sin límite**. No añadir Big Eater, nuevos mapas, dailies ni tiendas.
- Uno o dos commits lógicos con fast-forward y confirmación de HEAD remoto; reportar test real por bloque, versión de Studio y cualquier prueba solo simulada. Documentar de forma breve, no logs enormes.
- El usuario evaluará si se sienten divertidas persecución/carry pose y cooperación; las cifras 3 corazones/2 s/10–12 s son **hipótesis de test**, no métricas.
