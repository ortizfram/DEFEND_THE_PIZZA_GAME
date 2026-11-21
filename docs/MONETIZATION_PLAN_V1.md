# DEFEND THE PIZZA! — MONETIZATION PLAN V1
**Fecha:** 2026-11-21  
**Estado:** propuesta de catálogo, momento y operación. **NO IMPLEMENTADO / NO AUTORIZADO PARA VENTA.**  
**Fuentes de producto:** [GAME_DESIGN.md](GAME_DESIGN.md), [ROADMAP.md](ROADMAP.md), [ANALYTICS_SPEC.md](ANALYTICS_SPEC.md), [DECISIONS.md](DECISIONS.md).  
**Documentación oficial consultada:** [Monetization](https://create.roblox.com/docs/production/monetization), [Passes](https://create.roblox.com/docs/production/monetization/passes), [Developer Products](https://create.roblox.com/docs/production/monetization/developer-products), [Regional Pricing](https://create.roblox.com/docs/production/monetization/regional-pricing), [Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items), [Creator Rewards](https://create.roblox.com/docs/creator-rewards), [Monetization Analytics](https://create.roblox.com/docs/production/analytics/monetization).

## 0. Intención del modelo
- El jugador es un chef pequeño y defiende una pizza gigante. **Lo que se vende es estatus visual, identidad y celebración, no evitar una derrota**.
- Todas las habilidades esenciales (espátula eficaz, derribar enemigos, salvar y recuperar porciones, completar oleadas, reparaciones ganadas cuando existan) deben ser obtenibles sin Robux.
- Se puede progresar jugando sin pagar. Evitar tensión artificial, spam de compras, falsas ofertas urgentes, temporizadores manipulativos, compras en momentos de miedo/pérdida y elementos aleatorios pagados.
- El arte, la tienda y todos los pases son hipótesis hasta que el P0 graybox y las pruebas de comprensión y diversión hayan pasado.

## 1. Catálogo propuesto, con Robux de referencia (NO precios aprobados)

| Código conceptual | Artículo | Formato técnico | Precio base propuesto | Entrega exacta | Prioridad |
|---|---|---|---:|---|---|
| PASS_CHEF | Crazy Chef Pack | Game Pass (único) | **49 R$** | Tres gorros y dos delantales exclusivamente estéticos. Mismo tamaño de colisión y movilidad. | Primera venta piloto |
| PASS_SPATULA | Golden Spatula Pack | Game Pass (único) | **79 R$** | Una skin de espátula dorada y VFX/SFX cosméticos al impactar; **misma distancia, daño, cooldown y fuerza** que versión gratuita. | Primera venta piloto |
| PROD_PIZZA_PARTY | Pizza Party Celebration | Developer Product (repetible) | **19 R$** | **Una activación** de confeti/queso/fuegos artificiales cosméticos después de una victoria. El servidor gestiona el derecho consumible y la entrega; nunca afecta oleada ni pizza. | Después de validar pases |
| PASS_SUPPORTER | Master Chef Supporter | Game Pass (único) | **149 R$** | Traje de chef especial, insignia y pose de victoria exclusiva. Sin daño, XP, monedas ni protección extra. | Etapa posterior / público recurrente |

**Precios hipótesis de diseño:** no equivalen a precios efectivos vistos por todos los usuarios. No escribir 19/49/79/149 directamente en la UI: mostrar precios devueltos por Roblox para el jugador y usar los sistemas de precios regionales cuando correspondan. No crear IDs ficticios; incorporarlos a Config solo tras crear cada producto real en Creator Hub y probar su flujo.

**Gratis desde el principio:** espátula normal completa, skin chef básica, animación de victoria gratuita, todas las opciones de defender/recuperar, mejoras de combate ganadas dentro de la partida y al menos algunas recompensas cosméticas desbloqueables sin pago. Ninguna opción paga modifica el resultado competitivo.

**Backlog opcional a largo plazo (no al lanzamiento):** estelas de queso, delantales de temporada sin urgencias forzadas, emotes, skins de pizza visibles en un lobby propio (evitar cambiar en forma conflictiva la pizza compartida), decoraciones de vitrina; priorizar solamente lo que los jugadores disfruten mostrando. Suscripción, battle pass, donaciones, servidores privados, monedas vendidas por Robux y ads inmersivos **no** entran en este MVP; reabrir solo con datos que demuestren necesidad/valor.

## 2. Cuándo introducir monetización durante la PRODUCCIÓN

### G0 — Preproducción (ahora)
- Documentar catálogo, momento de exposición, hipótesis, eventos y reglas de seguridad. **0 productos reales, 0 prompts de compra, 0 Robux gastados.**
- Antes de generar assets finales probar la fantasía, título, thumbnail y competencia Roblox. No ampliar catálogo por anticipado.
### G1 — P0 greybox (primer golpe/oleada)
- **NO tienda ni compras.** Foco: golpe y knockback divertidos, pizza que pierde porciones, acciones iniciales comprensibles.
- Registrar funnel FTUE/rounds y datos del servidor. Diseñar servicios de configuración sin dependencia de IDs inventados.
### G2 — Ladrón y rescate (diferenciación)
- **NO compras**. Lograr porción robada → persecución → rescate satisfactorio y social.
- Continuar prueba de 1–2 clientes/móvil, sin ofrecer pagos para rescatar o evitar derrotas.
### G3 — MVP, 5 oleadas y pruebas de retención
- Construir **tienda visual opcional sin Robux/prompts**, con cosméticos gratis y previews.
- Probar usuarios nuevos (al menos 3–5 inicialmente) y medir primer golpe <10s, primera recompensa objetivo <30s, primera oleada, replay, sesión y luego retención de cohortes cuando haya experiencia publicada con consentimiento.
- En caso de confusión o abandono temprano, mejorar gameplay antes de activar ventas.
### G4a — Primer experimento comercial (necesita aprobación explícita)
- Activar únicamente **Crazy Chef Pack (49 R$ hipotéticos) y Golden Spatula Pack (79 R$ hipotéticos)**. Revisar precios/regiones con datos reales y visibilidad real del producto.
- Probar ownership de Game Pass en servidor al entrar/reentrar, durante compra, reversos y casos de free trial; equipamiento seguro y no transferible; sin doble entrega.
- Mostrar tienda únicamente por elección del jugador, entre oleadas o en lobby, después de haber experimentado el loop.
### G4b — Tras medir uso/conversión sin deterioro de retención
- Considerar **Pizza Party Celebration (19 R$ hipotéticos)**. Habilitarla **solo después de victoria y mediante un botón voluntario**; siempre mantener celebración gratuita.
- Implementar `MarketplaceService.ProcessReceipt` server-side, confirmación idempotente mediante `PurchaseId` persistido; resolver reintentos/reconexiones/crashes antes de declarar listo. Un solo handler central para developer products.
- Testear compra/entrega en servidores reales de prueba autorizados antes de marcar Listed en Shop.
### G5 — Juego recurrente
- Solo si hay audiencia que vuelve y solicita más expresión de identidad, evaluar **Master Chef Supporter (149 R$ hipotéticos)** y cosméticos estacionales. Ninguna fecha de introducción es obligatoria; los gates son conductuales, no de calendario.

## 3. Cuándo mostrar tienda DENTRO DE CADA SESIÓN

- **0–10 segundos:** objetivo pizza+monstruos+espátula, ninguna mención comercial.
- **Hasta primera oleada/recompensa:** no interrumpir con compra ni mostrar popups comerciales. La UI puede tener botón tienda secundario discreto, pero no desplazar el objetivo principal.
- **Tras primera victoria y pausa de oleada:** permitir explorar tienda cosmética desde botón opcional; no abrir compra automáticamente.
- **Lobby / pausa segura / pantalla final voluntaria:** vista previa del aspecto y precio real; botón Comprar deliberado, sin confundir moneda ganable con Robux.
- **Después de victoria:** opción de comprar celebración especial, con alternativa gratis. No durante crisis, pérdida de porción o derrota. No mostrar prompts forzados.
- Para sesiones cortas, no forzar largos tiempos de permanencia ni penalizar la salida. No retener a los jugadores por recompensa artificial.

## 4. Requisitos técnicos y de seguridad

### Pases permanentes
- Crear y asociar Game Passes al universo correcto **solo tras la publicación/autorización** pertinente.
- Al entrar, revalidar ownership con API oficial de Roblox; conceder estéticas que dependen de ownership actual, no un booleano manipulable desde cliente. No guardar permanentemente beneficios que deben revocarse ante cancelación/reembolso.
- No entregar mejoras de combate, compras durante la derrota ni acceso al loop principal de forma exclusiva.

### Developer products
- Comprar solo mediante el prompt oficial; **NO** conceder desde `PromptProductPurchaseFinished`; `ProcessReceipt` único en servidor es la autoridad.
- **Idempotencia estricta**: usar PurchaseId/registro durable y entrega atómica o recuperable; ante fallo persistente no confirmar `PurchaseGranted`; probar compras duplicadas, caídas, rejoin, servidor distinto.
- Para la celebración: pago compra una activación (o derecho almacenado para usarla si el jugador se desconectó), nunca un privilegio infinito. No ejecutar una segunda vez el mismo receipt.
- Proteger remotos con rate limit y checks de sesión/fase de victoria; no aceptar ProductId ni monto desde datos arbitrarios del cliente.
- IDs exactos en Config/archivo específico cuando existan; jamás inventarlos, y no colocar secretos.

### Precios y requisitos de plataforma
- Verificar políticas y elegibilidad en Creator Hub al crear cada ítem.
- Precio visible proviene de metadata recuperada de Roblox y debe coincidir con prompt/región; no hardcodear textos en UI.
- El juego está dirigido a público joven: **evitar lootboxes, gacha, ruletas y recompensas aleatorias pagadas**. Si algún día se proponen, es revisión nueva de reglas, probabilidades y restricciones por jugador; no están autorizadas.
- Mantener el catálogo simple, transparente, con alternativas gratuitas y sin urgencias falsas; los usuarios pueden abandonar una compra sin penalización.

## 5. Funnels y métricas — definir antes de cada experimento

**Funnel hipotético DTP_SHOP por visita a tienda:** `ShopOpened → ProductViewed → PurchasePrompted → PurchaseVerified`. Los pasos solo se registran si ocurrieron y en orden; `PurchaseVerified` exclusivamente después de confirmación real en servidor y entrega correcta. Si varios ítems se ven en orden libre, preferir eventos custom de vista y un funnel por intento de compra en vez de imponer pasos falsos.

**Eventos propuestos:** `DTP_ShopOpened`, `DTP_ProductViewed`, `DTP_PromptShown`, `DTP_PurchaseVerified`, `DTP_ReceiptRetry`, `DTP_RewardGranted`, `DTP_SkinEquipped`; auditarlos con versión y product_code sin IDs personales. No loguear por frame ni registrar la compra solo por cerrar un popup.

**Métricas:**
- Apertura tienda = jugadores únicos que abrieron / elegibles que completaron onboarding.
- Interés en ítem = visitantes únicos de ficha / visitantes únicos tienda.
- Conversión al prompt = compradores verificados / intentos de compra comparables; examinar cancelaciones y tiempos de atribución.
- Payer conversion = compradores únicos / usuarios únicos elegibles en periodo.
- Revenue neto por 1000 nuevos usuarios, earnings reales en Robux, ARPPU y ARPDAU cuando haya volumen.
- Ratio de recibos entregados exactamente una vez; rechazar lanzamiento con recibos sin entrega recuperable.
- **Guardrails:** tiempo de sesión, D1/D7 por cohortes, primeras recompensas, retry rate, bugs, FPS/móvil, quejas de pay-to-win y errores de pago.
- No asumir benchmarks universales de conversión o D1. Definir línea base interna, ventana, muestra suficiente y cambio aislado **antes** de decidir aumentar precio o catálogo.

## 6. Riesgos/decisión
- Riesgo 1: que una tienda temprana interrumpa el juego. Control: G1–G3 sin ventas ni popups.
- Riesgo 2: percepción de pay-to-win. Control: estéticas únicamente; misma física y fuerza para todos.
- Riesgo 3: UX de niños. Control: precios legibles, botón explícito y alternativa gratuita sin presión de tiempo.
- Riesgo 4: duplicación/no entrega. Control: QA de ownership y ProcessReceipt con casos de rejoin/reintento.
- Riesgo 5: catálogo sin demanda real. Control: pilotos secuenciales, no publicar cuatro ítems juntos ni prometer ingresos.

**Estado de autorización:** `PLANIFICADO — SIN PRODUCTOS CREADOS, SIN IDS, SIN COMPRA REAL, SIN SCRIPT DE VENTA`. Abrir G4 comercial requiere aceptación explícita del propietario, además de pruebas del juego y compliance de Roblox.
