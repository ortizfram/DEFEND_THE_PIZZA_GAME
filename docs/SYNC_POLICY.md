# Protocolo de sincronización — DEFEND THE PIZZA!

**Decisión del propietario (2026-11-21):** guardar cambios relevantes en el repositorio propio del juego y mantenerlos sincronizados con GitHub **al realizar cada tarea autorizada**. No hay sincronización permanente en segundo plano. Nunca declarar una sincronización exitosa sin leer el resultado remoto.

## Fuentes de verdad

- **Código, progreso e instrucciones del juego:** [`ortizfram/DEFEND_THE_PIZZA_GAME`](https://github.com/ortizfram/DEFEND_THE_PIZZA_GAME). Repositorio creado y accesible. Su visibilidad se detectó como **PÚBLICA** durante la primera sincronización; el propietario debe cambiarla en Settings si lo desea privado.
- **Conocimiento general, descubrimiento e investigación:** [`ortizfram/roblox-vault`](https://github.com/ortizfram/roblox-vault). Guía canónica de este concepto: `Projects/DefendThePizza/PREPRODUCTION_V01.md`.
- Si una decisión afecta a ambos, actualizar la fuente canónica y enlazar brevemente desde el otro. GitHub sincronizado no equivale a Roblox Studio LIVE sincronizado.

## Antes de cada trabajo

1. Leer `AGENTS.md`, `docs/DECISIONS.md`, `docs/ROADMAP.md`, `docs/SYNC_POLICY.md` y revisar el estado de `main`.
2. Confirmar repositorio y remoto exactos. Evitar STOMPIES, BOOP y DON'T WAKE THE GIANT.
3. Hacer `git fetch` y revisar diferencias del remoto antes de editar. Si hay commits nuevos, cambios sucios o divergencia, reconciliar; nunca forzar, resetear ni sobrescribir silenciosamente.
4. Para cambios en Studio, verificar Place, backup, conexión Rojo/MCP, autoridad del editor y permiso del propietario.

## Después de cada trabajo

1. Validar estructura (`python tools/validate_scaffold.py`), pruebas de código o gameplay relevantes y `git diff --check`.
2. Actualizar `docs/DECISIONS.md`, `docs/ROADMAP.md`, `CHANGELOG.md` y documentación de analíticas cuando cambien.
3. Revisar diff/secretos, hacer commit descriptivo, publicar a `main` con fast-forward y confirmar leyendo el HEAD remoto.
4. Reportar el hash remoto y los resultados reales: `REMOTE SYNC CONFIRMADO` o `NO SINCRONIZADO`, señalando bloqueos.
5. Si se modificó una regla reutilizable, actualizar además el vault con su propio commit verificado.

## Herramientas

`tools/sync_repo.ps1` (Windows) comprueba el remoto y permite estado, pull fast-forward y push; no usa `--force`. Para comenzar en otra PC **clonar este remoto**:

```powershell
git clone https://github.com/ortizfram/DEFEND_THE_PIZZA_GAME.git
cd DEFEND_THE_PIZZA_GAME
powershell -ExecutionPolicy Bypass -File tools/sync_repo.ps1 -Mode Status
```

**IMPORTANTE:** el ZIP Git generado ANTES de crear el remoto contiene un historial independiente. No hacer `git push` desde ese ZIP, pues GitHub ya tenía un commit inicial y fue preservado. Usar `git clone` del repositorio remoto actualizado para evitar historias divergentes.

Ninguna instrucción de sincronización por sí sola autoriza publicar el juego, gastar fondos ni cambiar otras experiencias de Roblox.
