# Combat & Revive — propuesta V0.2 (21/11/2026)

**Estado: DISEÑO PROPUESTO, no implementado ni aprobado como producto comercial.** El usuario sugirió que los zombies ataquen también a los jugadores para permitir un revive opcional en vez de quedar espectadores.

## Fantasía y objetivos
El juego sigue siendo `DEFEND THE PIZZA!`: los zombies quieren comerse la pizza. No deben perseguir jugadores permanentemente ni desviar la atención del objetivo principal.

| Enemigo | Objetivo principal | Contra jugadores | Gate |
|---|---|---|---|
| Munchie / zombie común | Comer pizza | Muerde al chef que se interpone, se acerca o lo golpea; tras un momento vuelve hacia pizza | P0 |
| Slice Thief | Robar porción y huir | Puede empujar si lo interceptan; no requiere gran IA de combate | G2 |
| Big Eater | Avanzar lento a pizza | Golpe telegrafiado a chefs cercanos, mucho empuje | G3 si aporta diversión |
| Biter (opcional) | Presionar chefs momentáneamente | Persigue al defensor durante pocos segundos y vuelve a pizza | Solo si test lo necesita |

**Loop:** zombies hacia pizza → chefs los golpean → algunos contraatacan → esquivar/salvar amigos → proteger/recuperar porciones → próxima oleada. La derrota del equipo se produce **cuando desaparece toda la pizza**, no por perder a todos los personajes durante unos segundos.

## Vida y rescates gratuitos (tiempos para playtesting, no reglas finales)

- Chef: **3 corazones** como hipótesis; mordida clara de zombie quita 1; breve protección al recibir impacto para evitar muerte injusta.
- Al perderlos: estado `DOWNED`, tumbado con icono de ayuda. Nunca quedar espectador el resto de la ronda.
- Otro chef puede revivirlo **gratis**, cerca y manteniendo pulsado `REVIVE` durante **~2 segundos** (botón móvil o tecla PC); servidor comprueba distancia, duración, estado.
- Si nadie llega, el jugador **reaparece gratis** cerca de la cocina en **10–12 segundos máximo desde la caída**, aunque juegue solo. Contador visible; sin perder la ronda por estar caído.
- Si todos caen y queda pizza, siguen disponibles los respawns gratis. Invulnerabilidad corta al levantarse, sin permitir abuso del spawn.
- Si 12 s es demasiado durante oleadas de ~30 s, bajar el tiempo. **No aumentar la espera para provocar compras**.
- El primer prototipo puede limitarse a zombie común que golpea a un chef y a la pizza; ladrones, tanques y monetización después.

## Revive instantáneo pagado (solo idea para evaluar, no aprobación)

**Producto candidato:** `PROD_INSTANT_REVIVE`, **Developer Product consumible**, precio ilustrativo **19 Robux** (no aprobado). Una compra otorga **un crédito** de auto-revive instantáneo al chef, sin restaurar ni reparar la pizza ni aumentar daño/vida adicional.

- Opción **completamente voluntaria**, precio visible real de Roblox, sin popup automático de compra cuando un jugador cae. No mostrar en el tutorial ni en la primera caída.
- Mantener siempre igual o más visible el contador de respawn gratis y el rescate por compañeros. Ninguna compra debe ser necesaria para participar.
- Si el pago se confirma después de que el jugador ya reapareció por la vía gratuita, **guardar el crédito para una futura caída**, no consumirlo ni perderlo.
- `MarketplaceService.ProcessReceipt` único en el servidor; validar receipt, idempotencia por `PurchaseId`, persistencia robusta de créditos y reconexiones, no fiarse de `PromptProductPurchaseFinished`. No inventar ProductId.
- Un revive pago durante una amenaza puede percibirse como **pay-to-win** y afectar retención. La opción debe evaluarse **solo después de** prototipo, revive gratis y test con jugadores (G4+), con autorización explícita. Si perjudica diversión o equidad, descartarla y mantener cosméticos.
- La duración natural de volver a jugar debe ser baja aunque eso haga que pocos compren. Monetización nunca debe determinar el castigo de morir.

Fuentes oficiales: [Developer Products / ProcessReceipt](https://create.roblox.com/docs/production/monetization/developer-products) y [Contextual Purchases](https://create.roblox.com/docs/production/game-design/contextual-purchases).

## Analítica y criterios de prueba
Eventos futuros, solo si se implementa la mecánica: `DTP_PlayerDamaged`, `DTP_PlayerDowned`, `DTP_TeamReviveCompleted`, `DTP_FreeRespawn`, `DTP_DownedSeconds`. Si algún día se autoriza el producto: `DTP_PremiumRevivePrompted`, `DTP_ReviveCreditGranted`, `DTP_ReviveCreditRedeemed`, siempre desde servidor tras recibo legítimo.

KPI con denominadores: caídas/jugadores por oleada, rescates/caídas con compañeros disponibles, segundos sin poder jugar/caída, respawns gratis/caídas, primera ola completada, retry, D1, duración de sesión y quejas. No fabricar datos.

**Preguntas de arte pendientes:** los enemigos eran monstruos hambrientos; `zombies cómicos` es una estética propuesta por el usuario, no confirmación definitiva. Evitar gore y mantener miniatura/primeros 5 segundos legibles.
