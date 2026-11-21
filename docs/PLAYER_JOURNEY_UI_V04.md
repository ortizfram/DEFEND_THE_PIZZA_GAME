# Player Journey, Loading, Lobby, Loadout, Shop & UX — V0.4
**Fecha:** 2026-11-21
**Estado:** GAME DESIGN PROPUESTO, ningún menú o Place implementado.
**Integración:** MAPS_AND_OBJECTIVES_V03.md, MONETIZATION_PLAN_V1.md, COMBAT_AND_REVIVE_V02.md.

## Principios de UX (Grade 3–4, no certificado para cada palabra)
- La experiencia responde a una pregunta: **SAVE THE PIZZA!**. Personaje visible, objetivo visible, un botón HIT y uno ACT contextual.
- Evitar onboarding pasivo y varios popups. Primera sesión: cargar → escena breve opcional (máx. 3 s) → PLAY destacado → spawn ante pizza con zombie visible en 5 s. Primer golpe objetivo ≤10 s; primera recompensa ≤30 s (objetivos, no datos).
- En menú: PLAY, SHOP, LOADOUT, DAILY y SETTINGS discreto. No llenar pantalla de 12 sistemas. Menús grandes, iconos, textos en inglés simple, traducciones/localización después; botones táctiles anchos, soporte mando y contraste.
- Nunca forzar lectura de normas de privacidad, compra, misiones o tutorial largo para jugar; seguir normas del sistema Roblox al introducir funciones reales.
- No bloquear entrada si falta perfil/datos por un fallo transitorio; manejar guardado en modo seguro sin recompensas persistentes hasta tener datos válidos.

## A. Pantalla de carga — no falsificar avance
**Aspecto:** ilustración grande de pizza + pequeño zombie robando porción + silueta de chef con espátula. Fondo de cocina desenfocado, logo DEFEND THE PIZZA!, pequeño texto "LOADING..." y ruedita de pizza rotatoria.
**Implementación futura:** LocalScript en `ReplicatedFirst` y una `ScreenGui` ligera; usar `game:IsLoaded()`/`game.Loaded` y esperar dependencias críticas del cliente, eliminar pantalla default cuando corresponde con `ReplicatedFirst:RemoveDefaultLoadingScreen()`. No crear barra de 0–100 % ficticia basada en `task.wait`; mejor indicador indeterminado de estado. Si cliente tarda, mostrar "Still loading..." + reconectar cuando sea útil, no sacar UI prematuramente ni cargar 400 assets.
**Audio:** sin música al inicio hasta carga; corto campanazo de pizzería al terminar si usuario no silencia.
**Objetivo de UX:** hacer visible el juego tan pronto como realmente se pueda; no alargar la espera por marketing.

## B. Lobby — un mismo Place primero
**Escena 3D:** mini-pizzería brillante con pizza giratoria, chef/avatar de pie con espátula, fondo con ventanales y zombies de cartón moviéndose. No ejecutar IA en lobby.
**Zona central:** botón grande PLAY; 3 tarjetas SHOP / LOADOUT / DAILY abajo; esquina sup. izquierda logo y nivel Chef; arriba derecha monedas y ajustes. Botón BACK grande en subpantallas.
**Primera visita:** sugerencia automática Pizza Shop + PLAY, sin votación, countdown ni teletransporte obligatorio. Si hay 1 jugador, puede empezar solo inmediatamente.
**Después de primera partida:** selector de mapa con 3 tarjetas ilustradas SHOP, STREET, FACTORY (bloqueadas solo si la progresión final requiere; no decidir aún). Si el jugador tiene amigos, pueden entrar en el mismo servidor y votar o seguir al líder sin esperar colas largas. **P0:** mismo Place, lobby mínimo como interfaz o área independiente; no crear 4 Places antes de validar.
**Botones extra futuros:** "Invite" y lista de amigos si realmente mejora co-play; nunca convertir en popup obligatorio.
**Estado de servidores:** mostrar loading/ready real; cambio de mapa/teleport opcional solo cuando exista infraestructura que lo justifique.

## C. Loadout — 3 slots visuales, no árbol de armas
- Slot 1 **CHEF LOOK**: gorro/delantal; 1 gratuito y cosméticos gratuitos/pagos desbloqueados.
- Slot 2 **SPATULA LOOK**: aspecto de espátula, mismo daño, hitbox y cooldown para todos; Golden Spatula del plan comercial se mantiene visual.
- Slot 3 **WIN POSE**: celebración/emote final, 1 gratuito; alternativas desbloqueables.
- Vista previa de chef en pedestal con giro lento; una sola tarjeta activa y botón **EQUIP**. No mostrar más de 5 tarjetas en móvil al mismo tiempo; scroll vertical.
- **Persistencia:** perfil servidor con equipamiento validado contra catálogo/ownership; nunca equipar sin poseer. Si compra de pase se revierte, volver a look gratuito. Si datos no cargan, fallback gratis y sin perder inventario.
- **Futuro no obligatorio:** coleccionar herramientas con estadísticas *ganadas* dentro de rondas, pero en V0.4 **no hay armas de poder permanente equipables**. Mejoras entre oleadas gratuitas por monedas de la partida cuando exista, no en la tienda Robux.

## D. Tienda en lobby, separada de loadout
- Dos categorías visibles: **COINS** (cosméticos obtenibles jugando) y **ROBUX** (pases de skins/celebraciones del documento monetización). G1–G3: Robux no activo; en P0 ni siquiera renderizar tienda si estorba.
- Ficha de artículo: imagen 3D real, nombre corto, tipo y precio real del servidor/plataforma; botón **BUY** o **EQUIP**; previa de sonido/VFX solo después de pulsar PREVIEW. Indicar claramente "Just a skin" en ítems pagados, sin ventaja.
- Nunca abrir PromptPurchase automáticamente al perder o quedar downed. Si se aprueba premium revive en G4+, tiene que convivir con respawn gratis y alternativa claramente visible; sigue NO aprobado.
- Mostrar únicamente entitlements existentes; no inventar IDs de GamePass ni Developer Product. Un botón compra no prueba receipt.
- Sonido de monedas moderado, no crear ruidos constantes por mirar tienda.

## E. Pantalla de Daily
Tres tarjetas grandes con progreso; ejemplo: "HIT 10 ZOMBIES" (4/10), "CLOSE 2 DOORS" (1/2), "WIN 1 MAP" (0/1). Icono de premio en coins y botón **CLAIM** al terminar.
- No activar modal diario sobre primera partida ni obligar a reclamar para jugar. Botón DAILY en lobby con punto discreto cuando hay premio.
- Objetivos generados en servidor elegibles para mapas desbloqueados y modo solo. Fecha de rotación y claim definidos en REWARDS_DAILY_AUDIO_V04.md.
- Si no se completa, conservar el juego jugable; no castigar ausencias ni rachas rotas.

## F. HUD de combate
**Arriba:** 8 iconos de porciones (faltan físicamente cuando son comidas) + "SAVE THE PIZZA" (se desvanece al entender) + ola "WAVE 2/3". Evitar healthbars duplicadas si la pizza ya comunica pérdida.
**Lado derecho:** botón HIT grande bajo pulgar; encima botón ACT si hay objeto cercano o compañero caído; ocultarlo si no corresponde o mostrarlo gris. Mantener controles nativos de cámara/movimiento. Carga para golpe fuerte al mantener HIT, sin botón nuevo.
**Lado izquierdo:** 3 corazones para chef, icono de compañero caído con distancia solo si es relevante, indicación de puerta abierta/fan listo con flecha contextual.
**Alertas:** solo una grande a la vez (prioridad: pizza a una porción; ladrón escapando; brecha de entrada; compañero downed); nunca texto cruzado ni 4 flechas simultáneas.
**Fin de ola:** 5–7 s para elegir upgrade gratuito de 2 opciones visuales, simple; si no elige, equipar mejora por defecto. No vender en medio del peligro.

## G. Final de partida y reintento
- Ganar: cámara de 2 s hacia pizza salvada, chefs saltan, queso/confeti breve, fanfarria. UI con coins/XP/objetivos diarios completados y PLAY AGAIN / NEXT MAP. No detener control por 10 s.
- Perder: zombie gigante muerde última porción, sonido cómico, "PIZZA GONE!" y TRY AGAIN inmediato. No mostrar compra de revive como condición de seguir.
- Recompensas no entregadas dos veces al desconectar/reintentar. Servidor finaliza partida una vez por matchId.

## H. Cutscenes cortas y salteables (no clips de una minuto)
1. **Intro primera partida:** 2.5–3 s (pizza → puerta tiembla → primer zombie → chef espátula), salto automático si jugador presiona PLAY o golpe; el zombie no inflige daño durante introducción. No hay diálogo de texto.
2. **Nueva ola:** 0.5 s texto WAVE X y sonido "ding" sin inmovilizar.
3. **Boss eventual (Factory):** 1.5–2 s reveal desde el túnel, "BIG ZOMBIE!" y movimiento cámara corto, opción Skip visible; solo si luego se implementa jefe.
4. **Victoria/derrota:** 2 s, saltable/reducible; prioridad al botón Replay.
5. **Accesibilidad:** ajustes "Reduce Camera Shake", "Reduce Motion", volumen Music/SFX. Todas las cinemáticas breves, no depender de audio para comprender, y evitar flash/blink.

## I. Reglas de producción
- No introducir loading falso, 3D lobby pesado, teleport multiverse, tienda real ni cinco tipos de cutscenes antes de P0 divertido.
- G0 diseño; G1 pantalla loading mínima real + botón PLAY y HUD; G2 loadout básico de skin gratis; G3 rewards/daily + tienda solo cosmética mock + cutscenes cortas; G4 servicios de pago solo tras autorización.
- Toda recompensa, progreso, misión y equipamiento se valida en servidor. Mostrar en UI optimista únicamente animaciones sin conceder saldo client-side.
- **Estado de hoy:** diseño, sin pantallas ni sonidos implementados.
