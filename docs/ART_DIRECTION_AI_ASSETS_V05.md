# DEFEND THE PIZZA! — Art Bible y pipeline GPT/Claude V0.5
**Fecha:** 2026-11-22 · **Estado:** dirección artística propuesta. NO hay modelos finales, archivos .blend, UI funcional ni assets aprobados por el usuario.
**Playbook compartido de Roblox Vault:** [Producción visual con IA](https://github.com/ortizfram/roblox-vault/blob/main/Playbooks/Roblox-Visual-Production-UGC-UI-3D-AI.md).
**Juego existente:** [GAME_DESIGN.md](GAME_DESIGN.md), [MAPS_AND_OBJECTIVES_V03.md](MAPS_AND_OBJECTIVES_V03.md), [PLAYER_JOURNEY_UI_V04.md](PLAYER_JOURNEY_UI_V04.md), [COMBAT_PHYSICS_ANIMATION_V04.md](COMBAT_PHYSICS_ANIMATION_V04.md).

## 1. Core fantasy visual
**Nombre interno de arte: TOY PIZZA PANIC**. Un mundo de juguetes gastronómicos donde pequeños chefs defienden una pizza enorme de zombies hambrientos y graciosos.
- Siluetas gorditas, esquinas redondeadas, partes grandes y legibles, estilo 3D cartoon pulido de juguete, no hiperrealismo ni voxel/Minecraft.
- **La pizza es siempre el héroe:** naranja/amarillo cálido ocupa el centro, ocho triángulos visibles que desaparecen al sufrir daño. Zombie en verdes frescos / azul menta (contrastan con pizza), ojos enormes, bocas exageradas, 100% sin sangre ni terror realista.
- Chef: figura pequeña con gorro alto y espátula más grande que su antebrazo. El punto focal de la acción es la espátula y el zombie que sale volando, no detalles miniatura de la ropa.
- **Look Roblox real:** mantener proporciones caricaturescas, materiales simples, iluminación brillante, avatares legibles. Evitar engañar con renders que muestren funciones o detalle no reproducible in-game.
- **Mood:** fresco, juguetón, slapstick, colores controlados y expresiones muy claras. Nada grunge oscuro, militar, tipografías de terror ni UI corporativa.

## 2. Paleta y sistema de UI (tokens externos)
Archivo máquina: [art/design_tokens.json](../art/design_tokens.json). Paleta inicial (no estado final aprobado):
- Pizza cheese: `#FFD166`; Tomato: `#EF5A4C`; Deep tomato / error: `#C43C40`.
- Zombie green: `#77CA63`; Zombie mint: `#59C9BE`; fondo cream: `#FFF7E7`.
- UI dark slate: `#233142`; panel warm: `#FFF0D0`; blanco: `#FFFFFF`.
- Botón PLAY: amarillo/queso + texto oscuro, amplio, contorno grueso y sombra suave; no usar texto blanco pequeño sobre amarillo.
- CTA secundario: mint + texto oscuro; danger: rojo profundo + texto blanco.
- Botones redondeados 12–18 px de referencia en mockups; 2–3 px bordes y sombra bajo relieve, toques de shine. UI nativa de Roblox siempre que sea posible (UIStroke, UICorner, UIGradient, UIListLayout, constraints y Universal Styling). No exportar la UI entera como una sola imagen PNG.
- Fuente: priorizar fuente Roblox incorporada y disponible en Studio, de personalidad redondeada y alta legibilidad; verificar `FontFace` real antes de codificar. No inventar familia ni subir tipografía sin licencia.
- **Iconografía**: 1 acción = 1 símbolo grande (espátula HIT, mano ACT, porción pizza vida, corazón vida chef, puerta CLOSE/FIX, auto PUSH, ventilador PRESS, compañero HELP, moneda Coin). Igual trazo visual, grosor y luz en todas.

## 3. Componentes UI por pantalla
| Pantalla | Componentes visuales | Una meta |
|---|---|---|
| Loading | logo, pizza giratoria liviana, zombie pequeño, estado de carga real | Esperar sin falsear porcentaje |
| Lobby | chef en pedestal, PLAY muy grande, tarjetas SHOP/LOADOUT/DAILY, coins/level pequeños | JUGAR |
| HUD partida | 8 porciones arriba, WAVE x/y, corazón chef, HIT grande, ACT solo cuando corresponda | DEFENDER |
| Daily | 3 tarjetas, icono + frase corta + progreso + CLAIM | ENTENDER META |
| Loadout | chef preview 3D, 3 slots Chef/Spatula/Win Pose, EQUIP | PERSONALIZAR |
| Shop | categorías Coins y Robux separadas, preview, precio desde Roblox, OWNED / BUY | ELEGIR SIN PRESIÓN |
| Result | pizza salvada/perdida, coins/XP, PLAY AGAIN/NEXT | REPETIR |
| Settings | sliders Music/SFX, reduce camera shake/motion, back | CONTROL |

**Reglas de UX:** móvil primero; notch, topbar y joystick protegidos; escala/diseño con AnchorPoint + Scale + UISizeConstraint/UITextSizeConstraint/UIAspectRatioConstraint y Layouts. Probar móvil angosto, 16:9, tablet 4:3 y gamepad focus. No más de un modal a la vez, no popups de compra en primera sesión, no texto largo; "HIT", "HELP", "PLAY". El objetivo lector 3.º–4.º grado es hipótesis que se testea, no prueba automática.

## 4. Biblioteca 3D propia — assets, forma y escala
**Prioridad P0, no crear todo a la vez:**
1. `DTP_Pizza_Hero`: pizza sobre plato/mesa redonda con **8 porciones separables** (visual claro de faltar una, sin malla supercompleja), pepperoni grandes, queso dorado con bordes redondeados, silhouette a 20 studs.
2. `DTP_Spatula_Default`: mango grueso color madera/crema y cabeza metálica enorme con bordes redondos; swing claro y fácil de adjuntar al avatar; pivote y empuñadura coherentes.
3. `DTP_Zombie_Munchie`: torso gordito verde, cabeza casi cuadrada redondeada, ojos enormes diferentes, dientes blandos, brazos estirados; animaciones idle/walk/prepare-bite/1st-hit-stagger/2nd-hit-flung. Enemigo común 2 hits.
4. `DTP_Shop_Door`: puerta redonda de pizzería con silueta que distingue OPEN/CLOSED/BROKEN, junta/pivote simple, grietas visibles al recibir ataque.
5. P0 incluir 3D props de escena básicos en Parts de Studio: pared, piso, mesa, ventana; no perder tiempo modelando cafeteras antes del golpe.

**P1 / P2:** `DTP_Zombie_Runner` 1 hit, `DTP_Zombie_Thief` 2 hits con porción en mano, `DTP_Zombie_BigEater` 5 hits, carrito de pizza Street, auto y contenedor empujables, ventilador Factory, gorros de chef cosméticos. El boss 12 hits, lobby detallado y sets UGC Marketplace quedan para después del MVP.
**Set de variantes:** misma familia de cabezas/ojos y materiales para reducir trabajo; zombies reconocibles por silueta (pequeño/alto, delgado corredor, enorme redondo). Reacciones como squash breve + knockback, no ragdoll con Constraints pesados por cada zombie.
**Dimensiones:** decidir en relación con avatar/hitbox real del prototipo; no fijar metros o studs definitivos desde el texto sin Studio. Registrar escala, pivot y medidas en cada asset brief.

## 5. Modelo 3D editable: requisitos y presupuestos iniciales (RBLX LAB, NO oficiales)
- **Master**: `.blend` (o `.bbmodel`) y script procedimental si hay. **Import**: `.fbx` / `.gltf` / `.obj` soportados por Studio según rig/material. Guardar fuente y export cuando realmente existan y tengan derechos verificables.
- **Silueta**: validar en pequeño en vista de juego. 3 colores principales/prop, 5 máximo; un detalle grande reconocible y un gesto/emoción.
- **Punto inicial de test de costo**: prop ≈300–1.000 tris, zombie común ≈1.500–3.500, boss ≈3.000–6.000, accesorio simple ≈300–1.000. Texturas 256/512 para la mayoría; 1024 solo hero cuando se justifique. **No son límites impuestos por Roblox**. Roblox documenta tope general 20.000 triángulos por mesh común; avatar Marketplace tiene requisitos distintos.
- Pivot/origen, normals, UV, nombres y superficies limpios. Collision invisible sencilla para rendimiento y física consistente, no usar cada diente 3D como collider. Material reusable y pocos draw calls.
- Zombie que usa animaciones: rig elegido y confirmado en Studio, nombres de joints coherentes, animations importadas/permissionadas. Nunca afirmar que se probó un rig si solo existe una captura.
- Permiso y procedencia de cada material/imagen en [art/asset_manifest.json](../art/asset_manifest.json). **Un asset con derechos no comprobados = BLOCKED**, aunque sea gratis.
- Si Studio Assistant genera un mesh, se vuelve borrador que pasa QA de aspecto, triángulos, escala, texturas, colisiones, scripts y permiso. No asumir acceso ni generación gratis ilimitada.
- **Marketplace UGC:** un gorro de chef en juego NO es automáticamente UGC global. Para venderlo como accesorio Roblox exige estructura/attachments, Avatar Setup, validación, moderación, elegibilidad y tarifas que pueden cambiar. Nunca publicar ni gastar sin aprobación.

## 6. Flujo inter-IA concreto
**GPT — director de arte y QA:** recibe la biblia y un asset brief, genera 2 propuestas claramente diferentes; se elige una por silueta, lectura y viabilidad. Puede producir referencia de imagen 2D cuando se solicite, sin fingir que entregó mesh ni UI programada.
**Claude Code — implementador 3D/UI:** consume una variante aprobada, desarrolla Blender Python auditable o archivo fuente editable real (solo si tiene acceso a herramienta), exporta FBX/glTF e importa a Place de prueba autorizado; para UI usa componentes/estilo reusable y estados. Reporta herramientas y pruebas efectivamente ejecutadas.
**GPT — revisión:** screenshots reales en Studio/Blender en tamaño móvil y desktop, densidad tri/texture, licencias, interacciones, estados y errores. Aprueba/REWORK documentando 2 mejoras concretas. La combinación de modelos no elimina revisión humana.

**Prompt para Claude en este juego** (copiar al trabajar):
```text
Tu repo es ortizfram/DEFEND_THE_PIZZA_GAME. Lee AGENTS.md, docs/ART_DIRECTION_AI_ASSETS_V05.md, art/design_tokens.json, art/asset_manifest.json, art/ASSET_BRIEF_TEMPLATE.md y los documentos funcionales estrictamente relacionados.
Tu tarea es una sola: [asset + id].
Antes de tocar Studio confirma Place/backup/Rojo y muestra brief, fuente/licencia, límites móviles y criterios de aceptación. Debes entregar fuente editable real si cuentas con Blender/Figma/Studio; si no, script procedural y pasos auditables como PARCIAL, nunca archivo ficticio.
No cambies código de combate por mejorar arte; no traigas scripts de terceros sin inspección, ni subas UGC global, ni hagas compras.
Después de producir, prueba importación/escala/UI/colisiones/móvil si existe herramienta, actualiza asset_manifest y changelog, commit y push remoto verificado si hay permiso; informa qué se probó de verdad.
```

## 7. Gates de calidad antes de decir PROFESSIONAL
1. A primera vista en pantalla chica sé **qué es** el objeto y **qué hago** con él.
2. Combina con paleta y siluetas del resto del juego; 2–3 capturas de Studio comparables, no renders con distinta luz.
3. Source editable presente **si fue prometido**; export importable; escala/pivote correctos; no colisiones raras.
4. Animación no atraviesa pared, mesa o avatar; estados hit/stagger/death claros; no efectos peligrosos o de gore.
5. Móvil: FPS, memoria y GPU aceptables comparando P0/P1; test en dispositivo real cuando exista.
6. UI: botones táctiles legibles y funcionales en safe area, rotación/size, mando, cargas, errores, disabled, feedback.
7. Derechos documentados, sin marcas ajenas ni reventa de assets de licencia incompatible; Creator Store sin backdoors.
8. Registra **QA_PASS / QA_REWORK / BLOCKED / PLANNED**, nunca "final" sin validación.

## 8. Prioridad ejecutiva
- **Ahora**: diseñar y revisar 1 zombie Munchie, 1 espátula, 1 pizza por porciones y 1 botón HIT, con fuente y preview. Solo mejorar de manera visual cuando el graybox de golpe sea divertido.
- **Después**: puertas y sus estados, pantalla de loading ligera, PLAY, HUD. Luego Thief/Big Eater/otros mapas.
- **Luego**: lobby, shop/Loadout/Daily, accesorios cosméticos gratis y paquetes en Robux cuando se autoricen.
- **UGC Marketplace** al final: accesorio chef original con licencia y especificaciones válidas, distinto del inventario interno.

**Especificación propuesta, no implementación real.** Esta nota no autoriza gastar, publicar, modificar Roblox Studio sin comprobar Place ni generar assets si el usuario no lo pidió.
