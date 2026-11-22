# P0 · regresión técnica del 22/11/2026
Build de código verificada contra main `68c7c829791cd4ffab324fc56afe9fed2f529dde`.
Place verificado: Defend The Pizza, 122513508386436. Los scripts servidor y cliente de Studio coinciden byte por byte con el repositorio. Sin conexión Rojo activa verificada. Se utilizó MCP en una sesión Play temporal.

## Entorno y alcance
Un cliente automatizado real de Studio llama a Hit:FireServer. El test alterna rondas pasivas y rondas con aproximación automática al enemigo y seis solicitudes de HIT por ráfaga. La aproximación automatizada elimina la medición de comprensión y destreza de un participante.
Reglas del juego sin cambiar duración ni daño. Estado final y porciones observados en cliente, contrastados con logs del servidor. Las pruebas locales de compilación Luau, reglas de Munchie y estructura pasaron.
Resultado de diez rondas: 5 derrotas con 0 porciones (impares) y 5 victorias con 8 (pares). Reinicios observados entre rondas. Ronda par inicial: 306 solicitudes; las otras cuatro: 288 cada una. No hubo bloqueo durante las ráfagas. Tras respawn se verificaron espátula, blade, HUD y binding HIT.

## Recurso 203785492
MarketplaceService:GetProductInfoAsync identificó AssetTypeId 3 (audio), nombre Pop Close Sound. El aviso de tipo incompatible reaparece al iniciar Play.
Sin coincidencias en búsqueda de todos los scripts ni en las propiedades de recursos inspeccionadas de la jerarquía Edit y del cliente.
No se identificó el solicitante. Queda abierto el rastreo en componentes internos o complementos de Studio y la comparación en cliente publicado autorizado.
No hay evidencia suficiente para sustituir recursos del juego.

## Pruebas cooperativas y móvil
La sesión anterior de esta conversación verificó dos clientes simulados: ambos cargaron HUD, atacaron, observaron articulaciones animadas y compartieron victoria. El servidor verificó persiana cerrada y reabierta. Esa prueba conserva su fecha y alcance, sin contarse como diez rondas cooperativas nuevas.
La sesión anterior verificó HIT en emulador iPhone 17 Pro y separó su área de salto. Teléfono físico, red lenta y observación humana siguen pendientes.
Usar P0_PLAYER_OBSERVATION.md para cinco sesiones anónimas y checklist física.

## Correcciones y próximos pasos
Esta revisión conserva la jugabilidad existente. No se verificó un error crítico que justificara una corrección de código.
Prioridades abiertas: localizar el solicitante del audio, comprobar controles y legibilidad en teléfono físico, observar comprensión e impacto con jugadores nuevos.
Gate humano pendiente. Slice Thief sigue condicionado al resultado del gate.
