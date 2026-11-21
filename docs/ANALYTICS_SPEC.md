# Analytics-first: especificación V0.1 — NO IMPLEMENTADO

**Principio:** registrar acciones validadas por el servidor, nunca confiar en cifras/recompensas enviadas por cliente. No simular métricas de publicación en Studio.

| Métrica | Denominador | Evento hipotético / fuente | Paso |
|---|---|---|---|
| Primer golpe | nuevos joins con controles listos | FTUE `FirstAttackValidated` | Gate 1 |
| Primer empuje | primeros golpes válidos | FTUE `FirstKnockback` | Gate 1 |
| Primer premio | nuevos jugadores | Custom `FirstReward` | Gate 1 |
| Primera ola | participantes de ola 1 | FTUE `FirstWaveCompleted` | Gate 1 |
| Repetición | rondas finalizadas | Funnel `RoundFinished` → `NextRoundStarted` | Gate 1 |
| Porción recuperada | robos de porciones | Custom `DTP_SliceRecovered`, `DTP_ThiefEscape` | Gate 2 |
| Retención D1, D7, sesión | cohortes reales | Dashboard Roblox Creator Hub | Publicado |

**Funnel FTUE propuesto:** `Joined → FirstAttackValidated → FirstKnockback → FirstWaveCompleted`. No inventar pasos; si una oleada termina sin primer empuje registrar lo que pasó, no forzar completitud.

**Implementación futura:** `AnalyticsService:LogOnboardingFunnelStepEvent`, `LogFunnelStepEvent`, `LogCustomEvent` según el contrato oficial vigente. Definir una versión por cambio, una sesión estable por intento, validación anti-duplicados y limits. Segmentos: nuevo/recurrente, tipo de dispositivo, versión, modo solo/grupo, sólo cuando la API lo permita. Las compras deben confirmarse por servidor y sin doble recompensa.

**Validación:** debug local en Studio; eventos reales comprobados en un Place publicado autorizado y luego `Analytics > View Events` de Creator Hub. No afirmar analytics operativa en scaffold.

## Funnel de monetización previsto — no implementado

La monetización se planifica por etapas y solo se activa tras superar los gates y obtener autorización. Ver [MONETIZATION_PLAN_V1.md](MONETIZATION_PLAN_V1.md). 

- Funnel comercial DTP_SHOP por visita/intento validado: `ShopOpened → ProductViewed → PurchasePrompted → PurchaseVerified`; no forzar orden ficticio para navegación libre, usar custom events para vistas.
- `PurchaseVerified` se registra **únicamente tras recibo verificado / ownership comprobado y entrega**. No confiar en `PromptProductPurchaseFinished` para Developer Products.
- KPIs: shop unique open rate / elegibles; view rate / open; verified purchases / prompts comparables; payer conversion / usuarios elegibles; net earnings por 1k; ARPPU/ARPDAU con fuentes reales.
- Guardrails: D1/D7, sesión, retry, errores de compra, claims de pay-to-win, experiencia móvil.
- Segmentos antes/después y por dispositivo; evitar IDs personales en custom fields; cada ítem tiene product_code y versión.

## Analítica propuesta: daño a chefs y rescates (no implementado)

Leer [COMBAT_AND_REVIVE_V02.md](COMBAT_AND_REVIVE_V02.md). Cuando se implemente: `DTP_PlayerDamaged`, `DTP_PlayerDowned`, `DTP_TeamReviveCompleted`, `DTP_FreeRespawn`, segundos downed, segmentado por solo/co-op y versión. Si se aprueba revive premium: `DTP_PremiumRevivePrompted`, `DTP_ReviveCreditGranted`, `DTP_ReviveCreditRedeemed` desde servidor, tras recibo real. Medir caídas/jugadores, segundos sin control, rescates/caídas elegibles, replay, D1 y duración de sesión. No aumentar esperas para monetizar.

## Analítica por mapa — propuesta V0.3, no implementada

Diseño en [MAPS_AND_OBJECTIVES_V03.md](MAPS_AND_OBJECTIVES_V03.md). Eventos servidor sugeridos: `DTP_MapStarted` (mapId, playerCount, versión), `DTP_MapObjectiveUsed` (CLOSE/FIX/PUSH/PRESS, éxito), `DTP_EntryBreached`, `DTP_MapFinished`, `DTP_MapReplay`. Métricas de comprensión: jugadores que usan primera interacción / jugadores que inician mapa, primeras entradas cerradas/activadas por tiempo desde spawn, pérdida de porciones por oleada, participantes que finalizan mapa, ratio replay por finalizadores; segmentar por solo/multijugador/móvil. Eventos validados en servidor y no duplicados.

## Recorrido, progreso y audio V0.4 — contratos a implementar, no eventos activos

Ver [PLAYER_JOURNEY_UI_V04.md](PLAYER_JOURNEY_UI_V04.md), [COMBAT_PHYSICS_ANIMATION_V04.md](COMBAT_PHYSICS_ANIMATION_V04.md) y [REWARDS_DAILY_AUDIO_V04.md](REWARDS_DAILY_AUDIO_V04.md). Medir carga real (no barra inventada), Play → primer hit, primero y tercer ataque validado, caídas, daño, zombis neutralizados y porciones salvadas. Para economy/dailies: `DTP_WaveRewardGranted`, `DTP_CoinsEarned`, `DTP_ChefLevelUp`, `DTP_DailyGenerated`, `DTP_DailyClaimed`, `DTP_DailyRewardFailed`, `DTP_CosmeticEquipped` (todos servidor/validados y sin datos personales). KPIs: primer hit / elegibles; mapa completado / entradas, daily completada / elegibles, diario reclamado / completados, earnings per match, reward failures; verificar D1/tiempo de sesión por cohortes. Dedupe por matchId/dayId/questId y guardar a intervalos seguros. No loguear golpes/eventos por frame ni confundir UI con entrega real.
