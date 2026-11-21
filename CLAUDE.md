# Claude Code — DEFEND THE PIZZA!

Primero lee `AGENTS.md`, luego `docs/DECISIONS.md`, `docs/ROADMAP.md`, `docs/SYNC_POLICY.md` y el módulo `src/shared/Config.luau`.

**Estado actual:** scaffold, sin gameplay ni Place conectado. No empezar a implementar sin orden del propietario. No ejecutar comandos que modifiquen una experiencia de Studio desconocida. Antes de editar: confirmar conexión Studio/Place, backup y rama Git.

Cuando se autorice P0: construir lo mínimo para demostrar que golpear enemigos es divertido, con servidor autoritativo y eventos de analítica desde el inicio. No añadir ladrón de porciones hasta superar P0. Mantener `README.md`, QA y CHANGELOG actualizados al implementar.

**Separación:** `ortizfram/roblox-vault` = conocimiento; este repo = código real. No escribir código de juego en el vault.

**Regla persistente:** al iniciar trabajo, verificar el remoto/estado; al terminar, registrar pruebas/decisiones, commit y push verificado con `tools/sync_repo.ps1` si GitHub está configurado. Nunca hacer force-push, auto-reset ni afirmar que GitHub equivale a Roblox Studio LIVE. Si no se puede subir, devolver `NO SINCRONIZADO` con causa.
