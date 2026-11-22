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

## Dirección de arte V0.5 — en evaluación, no assets creados
- El propietario pidió metodología gratuita para calidad profesional de **UGC, UI y modelado 3D con GPT/Claude** y que se guarde en Roblox Vault y se aplique a Defend the Pizza.
- Guía general canónica del vault: `Playbooks/Roblox-Visual-Production-UGC-UI-3D-AI.md`; específica del juego: [ART_DIRECTION_AI_ASSETS_V05.md](ART_DIRECTION_AI_ASSETS_V05.md).
- Estilo visual de trabajo propuesto **Toy Pizza Panic**: pizza naranja/queso como héroe, zombies verdes/menta de juguete, chef pequeño con espátula grande, UI redondeada y accesible móvil. Paleta/escala preliminares en `art/design_tokens.json`.
- GPT prepara briefs/QA; Claude Code implementa con acceso REAL a Blender/Studio y entrega fuente editable; ambos deben usar `art/asset_manifest.json` para licencia/QA/versiones. Un prompt no entrena pesos ni crea mallas por sí mismo.
- P0 planificado: pizza 8 porciones, espátula, Zombie Munchie de 2 golpes, puerta de Shop y botón HIT; no hay archivos modelo ni UI funcional aún.
- Crear accesorios cosméticos internos puede hacerse sin Marketplace. Publicación UGC avatar global puede requerir tarifas/elegibilidad/moderación y no se autoriza por esta planificación.

## DTP-3D-003 Zombie Munchie — blockouts A/B reales (2026-11-22)
- Claude Code generó en Blender 5.2.3 LTS dos fuentes editables reales y distintas: `art/source/Zombie_Munchie_A.blend` (Round, 3364 tris, 4.74 studs) y `art/source/Zombie_Munchie_B.blend` (Noodle, 3104 tris, 6.21 studs), con scripts reproducibles en `tools/asset_generation/`.
- **Recomendación de Claude: A (Round).** B se confunde con el Runner a 100 px, pierde contraste en la cámara de juego móvil y necesita 16 juntas contra las 10 de A. Detalle en [art/briefs/DTP-3D-003_Zombie_Munchie.md](../art/briefs/DTP-3D-003_Zombie_Munchie.md).
- **APROBADO por el propietario (2026-11-22): Munchie = Variante A (Round).** B se conserva como base posible del Runner. A recibió un rework menor (ojos/boca más grandes, piernas separadas) y se re-exportó en FBX/GLB, todavía sin rig.
- Convención de assets 3D: 1 BU = 1 stud (Unit System None), personaje mirando a -Y, pies en Z = 0 y origen de cada pieza en su articulación. FBX: Forward Z, Up Y, FBX Unit Scale (según la documentación de Roblox para Blender).
- Rig para P0: Motor6D rígido segmentado (sin skinning), **construido y probado en Studio el 2026-11-22** con `tools/studio/rig_munchie_a.luau`. El Importer de Studio descarta los colores de material planos del FBX: **convención adoptada: palette texture compartida** (`art/source/textures/T_Munchie_Palette.png`, índices fijos, solo se agregan colores) para todos los zombies.

## Aún no verificado
- Datos detallados del análisis de Creator Exchange (URLs, visitas, fechas); no inventar.
- Original fuera de Roblox con filtros cuantitativos; competidores directos actualizados.
- Thumbnail final; prototipo jugable y test con jugadores.
- Conexión a un Place de Roblox Studio y test real.

## No autorizado por este documento
- Publicar experiencias Roblox, invertir en Ads, comprar assets, activar monetización o cambiar otros juegos.

**Diseño completo:** https://github.com/ortizfram/roblox-vault/blob/main/Projects/DefendThePizza/PREPRODUCTION_V01.md

## Implementación P0 · 22/11/2026
Se priorizó una oleada de Pizza Shop. La persiana bloquea durante 4 s a los enemigos que llegan por la entrada central. Munchie recibe dos golpes. El prototipo clona el rig presente o usa un bloque provisional en un Place vacío. Balance, mordida al chef, reproducción de clips y QA móvil quedan abiertos.

## Integración autorizada en Studio · 22/11/2026
El propietario autorizó a Codex a editar este Place para terminar el playtest. Se reutilizan secuencias originales guardadas en ServerStorage. El servidor decide el estado del enemigo y cada cliente interpola sus poses de Motor6D. AttackChef queda reservado para la mecánica de daño a chefs. Se apartan los modelos de referencia del mapa durante la ejecución.

## Solicitud de gameplay y especificación P0 V0.6 — 2026-11-22
El propietario solicitó ampliar la distancia de vuelo/ragdoll y exagerar la animación de espátula. Solicitó que **cada porción requiera tres mordidas** y comparar con el zombie común de Plants vs. Zombies. La consulta externa indica girasol normal ~300 HP y zombie común ~100 daño/s, destrucción ~3 s; PvZ no necesariamente aplica un contador discreto de tres mordidas. Para Roblox se elige tres golpes discretos compartidos por todos los zombies que mastican una misma porción, con telegraph/impacto claro. Munchie conserva 2 HP; ragdoll real solo con rig A, fallback con bloque visual. Detalle [COMBAT_TUNING_PVZ_V06.md](COMBAT_TUNING_PVZ_V06.md). **Implementación GitHub requiere QA de Studio antes de marcar completa**; no autoriza monetización ni publicación.
