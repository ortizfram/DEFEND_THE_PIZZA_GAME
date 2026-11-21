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
