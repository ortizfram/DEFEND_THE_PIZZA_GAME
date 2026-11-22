# AGENTS — DEFEND THE PIZZA! (repo de juego)

Este es el **código del juego**, NO la biblioteca de conocimiento. Consultar el [vault](https://github.com/ortizfram/roblox-vault) para decisiones generales; consultar `docs/DECISIONS.md` y `docs/ROADMAP.md` antes de cambios.

## Normas de operación

1. Este repo **no tiene un Place conectado verificado** y el código actual es un scaffold. Nunca afirmar que el juego está listo o publicado sin evidencia de test.
2. **Claude Code = responsable único de editar/probar en Roblox Studio cuando el usuario autorice**; otros agentes pueden revisar código, propuestas e issues pero no cambiar en paralelo una instancia de Studio.
3. Antes de tocar Roblox Studio: comprobar Place, conexión MCP/Rojo, respaldar proyecto actual y asegurar que NO es STOMPIES, BOOP ni DON'T WAKE THE GIANT.
4. Trabajo por incrementos mínimos; un commit por comportamiento probado. Preferir `src/` a cambios manuales invisibles en Studio. Registrar diferencias y estado de sincronización.
5. Backend autoritativo: servidor valida golpes, salud/porciones, monedas, recuperación de robos, rewards y recibos. RemoteEvents con rate limit, checks de distancia/timing y sin premios desde cliente.
6. Móvil primero; PC y consola sin conflicto de controles. El primer golpe visible debe tener feedback rápido. No instalar scripts/plugins de terceros sin auditar.
7. Cada mecánica nueva requiere hipótesis + KPI/denominador + eventos registrados en servidor + QA + versión. Usar documentación de `docs/ANALYTICS_SPEC.md`; nunca simular métricas de usuarios reales.
8. No publicar, gastar Robux/ad credits, activar monetización ni ejecutar cambios destructivos sin aprobación expresa del propietario.
9. No llenar el juego de cosméticos, guías largas, mapa grande ni UI compleja antes de probar el primer loop de 30 s.
10. Reportar cambios con: archivos, acciones en Studio, pruebas realizadas, bugs pendientes, versión y condición COMPLETADO / PARCIAL / BLOQUEADO.

## Source of truth

- `docs/DECISIONS.md`: decisiones aprobadas y supuestos.
- `docs/GAME_DESIGN.md`: definición compacta del juego; link al documento completo del vault.
- `docs/ROADMAP.md`: gates de desarrollo.
- `docs/ANALYTICS_SPEC.md`: contratos de eventos a implementar, no eventos ya existentes.
- Roblox Vault: guía de investigación, naming, miniaturas y anuncios.

## Documento de diseño V0.4, leer selectivamente

- Antes de diseñar HUD/lobby, abrir `docs/PLAYER_JOURNEY_UI_V04.md`.
- Antes de tocar combate/IA/animaciones, abrir `docs/COMBAT_PHYSICS_ANIMATION_V04.md`.
- Antes de desarrollar progreso/recompensas/música, abrir `docs/REWARDS_DAILY_AUDIO_V04.md`.
- Los valores numéricos son hipótesis de playtest. No implementar estos sistemas en bloque por existir especificaciones; seguir gates de `docs/ROADMAP.md`.

## Arte, UI, UGC y modelado 3D con GPT/Claude — leer por tarea

- Director de arte canónico: [docs/ART_DIRECTION_AI_ASSETS_V05.md](docs/ART_DIRECTION_AI_ASSETS_V05.md), colores/escala/estilo en `art/design_tokens.json`, registro fuente/licencia/estado en `art/asset_manifest.json`.
- Brief por asset: `art/ASSET_BRIEF_TEMPLATE.md`; prompts especializados para ambos modelos: `art/AI_ASSET_PROMPTS.md`. Playbook universal en `roblox-vault/Playbooks/Roblox-Visual-Production-UGC-UI-3D-AI.md`.
- **No confundir referencia/render PNG con mesh editable .blend/.fbx, ni mockup Figma con botones Roblox funcionales.** Estado `APPROVED` requiere fuente real, export/QA, derechos y verificación en Studio/móvil.
- Los budgets/colores/nombres del diseño son **propuestas**, no resultados probados. No publicar UGC Marketplace, activar compras ni instalar plugins no auditados sin permiso expreso. Primero P0 funcional y divertido.

## Regla permanente de sincronización (solicitud del propietario 21/11/2026)

Antes y después de **cada cambio autorizado**, seguir `docs/SYNC_POLICY.md`: comprobar `git status` y remoto, actualizar archivos de decisiones/changelog, ejecutar QA, hacer commit y push a `ortizfram/DEFEND_THE_PIZZA_GAME` cuando el remoto exista. Para conocimiento general, actualizar el `roblox-vault` por separado y enlazar. No afirmar push si no se verificó el commit remoto. No forzar ni sobrescribir trabajo ajeno. Sin remoto/credenciales, marcar `NO SINCRONIZADO` y proporcionar artefacto local. Git no sustituye la sincronización comprobada con Roblox Studio.
