# Registro de decisiones — DEFEND THE PIZZA!

Fecha de inicio: 2026-11-21.

## Aprobado por el propietario
- Nombre: **Defend the Pizza!**
- Keyword principal `Defend` investigada por el propietario en Creator Exchange.
- Comprensión reportada: **3.º–4.º grado** de inglés.
- Continuar el diseño y crear **un repositorio independiente del vault**.

- **Sincronización de información:** después de cada tarea autorizada, guardar cambios documentales/de código en el repo del juego y sincronizar por GitHub, comprobando el push (solo cuando exista el remoto y permisos). Mantener el vault como fuente de reglas generales. Véase `docs/SYNC_POLICY.md`.

## Propuestas de diseño (NO aprobadas individualmente)
- Core fantasy: pequeños chefs defienden pizza gigante de monstruos hambrientos.
- Arcade cooperativo de defensa física, no tower defense pasivo.
- Diferenciador propuesto: ladrones arrancan porciones y huyen; jugadores pueden recuperarlas.
- Público: 9–15 años, móvil primero; 1–6 jugadores como parámetro de prototipo.
- Estructura propuesta: pizza con 8 porciones, 3 rutas, golpe de espátula, 1 enemigo para P0 y upgrades después.
- Thumbnail storyboard: chef a izquierda, pizza gigante centro, ladrón a derecha con queso elástico.

## Planificación de monetización — propuesta, NO aprobada para activar
- El propietario solicitó planificar **qué monetizar, cómo y cuándo**. Es una petición de diseño/documentación, **no** autorización de compras o publicación.
- Propuesta V1: pases estéticos de chefs (49 Robux), espátulas (79 Robux), celebración consumible post-victoria (19 Robux) y Supporter (149 Robux); **todos los precios hipotéticos** hasta datos reales.
- En G1–G2 no vender; en G3 solo interfaz cosmética gratuita; tras pruebas, G4a pases; G4b celebración; G5 Supporter si hay retención.
- Regla: vender identidad/celebración, nunca daño, alcance, protección de porciones o salvación por Robux. No lootboxes pagas.
- Plan fuente: [docs/MONETIZATION_PLAN_V1.md](MONETIZATION_PLAN_V1.md).

## Propuesta en estudio: ataques a jugadores / revive, no decisión aprobada
- El propietario planteó que zombies también dañen a jugadores y permitir un revive opcional de compra, evitando quedar de espectadores.
- Recomendación registrada: zombies priorizan pizza, contraatacan a chefs cercanos; 3 corazones propuestos, DOWNED y rescate gratis entre compañeros (2 s), respawn gratis ≤10–12 s. Derrota = pizza destruida.
- **No aprobado para venta:** revive instantáneo opcional 19 Robux hipotéticos (Developer Product), con alternativa gratuita, créditos durables y receipt idempotente. Primero medir si el combate/revive gratis aumenta diversión; vigilar pay-to-win.
- Documento: [COMBAT_AND_REVIVE_V02.md](COMBAT_AND_REVIVE_V02.md).

## Propuesta V0.3: tres mapas fáciles de comprender — pendiente de playtest
- El propietario solicitó imaginar 3 mapas y tareas para impedir o retrasar la entrada de zombies con un nivel de comprensión de 3.º–4.º grado.
- Se propone conservar SAVE THE PIZZA como misión principal y dos botones fundamentales: HIT y ACT contextual; cada mapa introduce una sola acción: Pizza Shop CLOSE/FIX puertas; Pizza Street PUSH auto/contenedor; Pizza Factory PRESS botón/ventilador.
- Metas secundarias opcionales (2 puertas, 2 callejones, 2 activaciones del ventilador) no son condición para ganar; puertas/obstáculos ceden bajo ataques y el ventilador tiene cooldown.
- Progresión tentativa de 3/4/5 oleadas. Primero desarrollar/validar solo Shop gris; solo entonces Street y Factory. Palabras de interfaz son propuestas y requieren prueba real de comprensión, no grade levels certificados.
- Documento de especificación: [MAPS_AND_OBJECTIVES_V03.md](MAPS_AND_OBJECTIVES_V03.md). No existe mapa implementado ni assets finales.

## Propuesta V0.4 — experiencia integrada (diseño, no aprobado como configuración final)
- El propietario pidió imaginar recompensas, objetivos diarios, pantalla de carga, lobby/menu antes de partida, tienda y loadout, físicas de golpes, HP/golpes por enemigo, movimiento/animaciones, cutscenes y música.
- Tres documentos propietarios: [PLAYER_JOURNEY_UI_V04.md](PLAYER_JOURNEY_UI_V04.md), [COMBAT_PHYSICS_ANIMATION_V04.md](COMBAT_PHYSICS_ANIMATION_V04.md), [REWARDS_DAILY_AUDIO_V04.md](REWARDS_DAILY_AUDIO_V04.md).
- Primer ingreso sin interrupciones: loading real → lobby PLAY visible → Pizza Shop → primer hit, objetivo ≤10 s tras entrar al mapa. Loadout con 3 slots cosméticos (Chef Look, Spatula Look, Win Pose), tienda Coins/Robux opcional, daily con 3 metas; sin mostrar compras en tutorial.
- Balance propuesto de zombie: Runner 1 HP/golpe, Munchie 2, Thief 2, Big Eater 5, boss 12 opcional. Slap tap =1 HP, charge hold 0.55s =2 HP con recuperación más lenta, 3er tap puede ser remate automático. Chef 3 corazones + revive/respawn gratis. Pizza sigue 8 porciones. Todos los números sujetos a prototipo, no hechos.
- Economía hipotética: Coins + Chef XP (cosméticos, no stats de pago), 10 Coins/oleada + 50 Shop/70 Street/90 Factory por victoria, tres quests diarias elegibles y posibles solo; UTC reset, servidor con UpdateAsync e idempotencia.
- Música propuesta original o con permiso de Creator Store; SFX claros por acción; cutscenes ≤3 s y salteables, settings de audio/Reduce Motion. No se creó asset ni ID real.
- **No hay gameplay implementado ni Place ni monetización activa**; orden de ejecución P0 gris → rescate y robo → recompensas/tienda visual → polish/anim/audio, nunca al revés.

## Aún no verificado
- Datos detallados del análisis de Creator Exchange (URLs, visitas, fechas); no inventar.
- Original fuera de Roblox con filtros cuantitativos; competidores directos actualizados.
- Thumbnail final; prototipo jugable y test con jugadores.
- Conexión a un Place de Roblox Studio y test real.

## No autorizado por este documento
- Publicar experiencias Roblox, invertir en Ads, comprar assets, activar monetización o cambiar otros juegos.

**Diseño completo:** https://github.com/ortizfram/roblox-vault/blob/main/Projects/DefendThePizza/PREPRODUCTION_V01.md
