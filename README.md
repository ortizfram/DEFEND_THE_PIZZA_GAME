# DEFEND THE PIZZA! — Roblox Game

**Estado:** repositorio inicial de código — PREPRODUCCIÓN / SCAFFOLD V0.1 (2026-11-21). **No hay gameplay funcional todavía.**

Juego cooperativo arcade de defensa física: chefs diminutos protegen una pizza enorme de monstruos hambrientos. El diferenciador propuesto es que ciertos monstruos **roban porciones y corren hacia una salida**; los jugadores pueden recuperarlas golpeándolos.

## Separación de responsabilidades

| Repositorio | Propósito |
|---|---|
| **Este: `ortizfram/DEFEND_THE_PIZZA_GAME`** | Código Luau, Rojo, pruebas, assets del juego cuando existan, issues/PRs, releases |
| [`ortizfram/roblox-vault`](https://github.com/ortizfram/roblox-vault) | Investigación, guías de creación de juegos, reglas de naming y publicidad; no código del juego |

**Diseño canónico:** [Preproducción V0.1](https://github.com/ortizfram/roblox-vault/blob/main/Projects/DefendThePizza/PREPRODUCTION_V01.md). Este repo contiene una versión ejecutiva en `docs/` para facilitar trabajo sin conexión.

## Inicio rápido (Windows)

1. El repositorio remoto existe en [GitHub](https://github.com/ortizfram/DEFEND_THE_PIZZA_GAME); fue detectado como **PÚBLICO** al sincronizar inicialmente. Para mantenerlo privado, el propietario debe cambiar la visibilidad en Settings > General > Danger Zone. No subir datos sensibles.
2. Clonar este repositorio (no usar el ZIP anterior con historial Git distinto):
   ```powershell
   git clone https://github.com/ortizfram/DEFEND_THE_PIZZA_GAME.git
   cd DEFEND_THE_PIZZA_GAME
   ```
3. Instalar y abrir **Roblox Studio** y el **plugin Rojo** de una fuente confiable. Instalar el ejecutable Rojo por el método oficial de tu elección y verificar `rojo --version`.
4. Abrir un **Baseplate NUEVO**, sin usar STOMPIES, BOOP ni DON'T WAKE THE GIANT. Ejecutar en la carpeta `rojo serve default.project.json`, conectar el plugin Rojo desde Studio al proyecto e inspeccionar la jerarquía. No sincronizar sobre un Place existente sin backup.
5. Verificar que aparezcan `ReplicatedStorage/DTP`, `ServerScriptService/DTPServer` y `StarterPlayer/StarterPlayerScripts/DTPClient`. Por ahora solo hay bootstrap/logs y un módulo de configuración; **no se crean modelos ni se publican experiencias**.
6. Correr `python tools/validate_scaffold.py` para verificar la estructura. Cualquier próxima etapa requiere pruebas locales y gate correspondiente.

## Estructura

```text
DEFEND_THE_PIZZA_GAME/
├── AGENTS.md                     Instrucciones universales de IA
├── CLAUDE.md                     Instrucciones a Claude Code
├── default.project.json          Mapeo Rojo
├── src/
│   ├── shared/Config.luau        Config de partida (provisional)
│   ├── server/Bootstrap.server.luau
│   └── client/Bootstrap.client.luau
├── docs/
│   ├── GAME_DESIGN.md            Resumen de fantasía, mecánica, primer minuto
│   ├── ROADMAP.md                Gates de implementación
│   ├── ANALYTICS_SPEC.md         Métricas/eventos a implementar
│   ├── QA_CHECKLIST.md           Pruebas antes de llamar 'funcional'
│   ├── DECISIONS.md              Aprobaciones vs hipótesis
│   └── SYNC_POLICY.md            Procedimiento para cada sesión
├── tools/validate_scaffold.py    Comprobaciones estáticas de estructura
└── tools/sync_repo.ps1           Verificación/pull/push seguro
```

## Límites

- **Una sola IA escribe el juego en Studio:** Claude Code cuando se le autorice. ChatGPT colabora en diseño/revisión y el vault.
- No editar otros repos/Places. Proteger datos del servidor; no confiar en RemoteEvents del cliente para premios ni daño.
- No instalar assets, scripts ni plugins no auditados.
- No prometer funcionalidad, publicación, monetización, datos de Analytics o campaña cuando no hay prueba.
- Previo a compras/Ads: aprobación explícita del propietario.

## Plan de monetización (todavía no activada)

[MONETIZATION_PLAN_V1.md](docs/MONETIZATION_PLAN_V1.md): catálogo estético propuesto, precios hipotéticos, momento para ofrecer compras, etapas G0–G5, manejo de recibos, métricas y pruebas. El juego sigue **sin gameplay y sin compras implementadas**; no crear productos ni ventas sin autorización.

## Mapas y objetivos V0.3 (diseño no implementado)

[MAPS_AND_OBJECTIVES_V03.md](docs/MAPS_AND_OBJECTIVES_V03.md): tres mapas progresivos con **una sola acción nueva por escenario**, interfaz entendible para 3.º–4.º grado y tareas de bloquear entradas sin perder la misión de salvar la pizza. Crear primero solo Pizza Shop P0.

## Experiencia V0.4 — Especificaciones de diseño, NO implementadas

- [Pantalla de carga, lobby, loadout, tienda, HUD y cutscenes](docs/PLAYER_JOURNEY_UI_V04.md)
- [Físicas, golpe de espátula, HP por zombie, animaciones y movimiento](docs/COMBAT_PHYSICS_ANIMATION_V04.md)
- [Recompensas, Coins y XP, objetivos diarios, música y sonido](docs/REWARDS_DAILY_AUDIO_V04.md)

**No confundir estos diseños con gameplay ya existente.** Programar primer golpe y pizza en un solo mapa antes de las tiendas, sonido final o misiones.

## Producción artística con IA — estilo V0.5 (plan, no assets reales)

- [Art Bible Toy Pizza Panic + pipeline 3D/UI/UGC](docs/ART_DIRECTION_AI_ASSETS_V05.md)
- [Tokens de UI / colores](art/design_tokens.json)
- [Registro de assets con licencias y estado](art/asset_manifest.json)
- [Brief obligatorio antes de crear cada asset](art/ASSET_BRIEF_TEMPLATE.md)
- [Prompts listos para GPT y Claude Code](art/AI_ASSET_PROMPTS.md)
- [Guía de producción visual para todos los juegos (Roblox Vault)](https://github.com/ortizfram/roblox-vault/blob/main/Playbooks/Roblox-Visual-Production-UGC-UI-3D-AI.md)

El diseño es una propuesta. **Ninguno de los 8 assets planificados existe como .blend/.fbx o GUI jugable por crear el manifest.** La aprobación de Marketplace UGC es un flujo distinto al uso de cosméticos internos.

## Primer modelo 3D: qué instalar en Windows

[SETUP_WINDOWS_FIRST_MUNCHIE.md](docs/SETUP_WINDOWS_FIRST_MUNCHIE.md): descargas oficiales (Blender, Roblox Studio, Git, VS Code, Claude Code opcional, Rojo cuando se programe), comandos para clonar GitHub, dos variantes de Zombie Munchie y proceso para crear .blend editables, elegir silueta, exportar/importar y verificar QA. **No implica que el modelo exista todavía.**

## Primer asset 3D real — Zombie Munchie (DTP-3D-003, en progreso)

Hay dos blockouts editables en Blender (`art/source/Zombie_Munchie_A.blend` y `_B.blend`), renders comparativos en `art/renders/munchie/` y un export candidato de A en `art/export/`. Brief y evaluación: [art/briefs/DTP-3D-003_Zombie_Munchie.md](art/briefs/DTP-3D-003_Zombie_Munchie.md). Para regenerarlos: `powershell -ExecutionPolicy Bypass -File tools/asset_generation/run_all.ps1` (requiere Blender 5.2). Todavía **no** se importó en Studio y no hay rig ni NPC.

## Próximo hito

**P0**: una cocina gris, una pizza con 8 porciones visuales, un enemigo, espátula con golpe/knockback y una ronda corta, con entradas de analítica desde el comienzo. Si el golpe no es divertido, no desarrollar el resto.

## Sincronización permanente

Consultar **[docs/SYNC_POLICY.md](docs/SYNC_POLICY.md)**. Después de cada cambio autorizado, las IAs deben revisar el diff, validar, actualizar decisiones y changelog, hacer commit y confirmar el push a GitHub. Esto **no** se ejecuta permanentemente por sí solo: requiere una sesión, remoto y permisos. Nunca modificar otros juegos, forzar pushes ni confundir GitHub con el Place real de Roblox Studio.

```powershell
powershell -ExecutionPolicy Bypass -File tools/sync_repo.ps1 -Mode Status
# Después de revisar los cambios y aprobar el commit:
powershell -ExecutionPolicy Bypass -File tools/sync_repo.ps1 -Mode Push -Message 'docs: update game decisions'
```
