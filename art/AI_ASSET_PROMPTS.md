# Prompts de producción visual — GPT + Claude para Defend the Pizza
**Importante:** prompts no entrenan pesos de modelos. Guían un trabajo reproducible. Si no existe un archivo, no declarar que fue generado. El proyecto necesita implementación real a través de herramientas.

## A. GPT — diseñar Zombie Munchie (P0)
```text
Leé docs/ART_DIRECTION_AI_ASSETS_V05.md, art/design_tokens.json y art/ASSET_BRIEF_TEMPLATE.md.
Necesito DTP-3D-003: Zombie Munchie, 2 golpes con espátula; primer golpe tambalea, segundo vuela. Desde cámara Roblox móvil debe verse claramente divertido, no terrorífico. 
Proponé 2 siluetas low-poly diferentes. Usá paleta zombis verde/menta, boca grande, ojos visibles y 1 motivo único. Describí vistas frente/lado/trasera, piezas separadas aptas para rigging simple, escala relativa al chef, budget <=3500 tris como TARGET INTERNO, y animaciones walk/bite/hit1/hit2.
Entregá un asset brief (Markdown) y un checklist de aceptación, señalando qué necesita revisión visual. No digas que entregaste mesh si solo entregás texto o imagen.
```

## B. Claude Code — modelar asset con herramientas accesibles
```text
Repo exclusivo ortizfram/DEFEND_THE_PIZZA_GAME. No cambiar otros juegos ni publicar.
Leé AGENTS.md y art bible/token/manifest; usá sólo el brief aprobado DTP-3D-003.
Comprobá si Blender y su ejecución en background están realmente disponibles. Si están: creá fuente .blend y un script Python de Blender determinista que regenere el zombie en piezas organizadas con nombres, escala/pivote y material correctos; exportá .fbx o .gltf a carpeta importable. Guardá scripts en tools/asset_generation y fuente en art/source (solo si el archivo existe). 
Si Blender no existe: generar código y README de ejecución pero MARCAR PARCIAL, no fingir .blend ni mesh exportado.
Probar import en Studio solo con Place autorizado, confirmar collisions/UV/rig/tamaño/tris, screenshot mobile, actualizar manifest y CHANGELOG; sincronizar commit GitHub verificado. Limitar alcance a este asset, no implementar IA del zombie ni tienda.
```

## C. GPT — revisar una captura
```text
Usá la Art Bible de Defend the Pizza y esta captura real del viewport con tamaño móvil.
Evaluá 1) si identifico zombie/spatula/pizza en 3s 2) coherencia de material, shape y color 3) contraste de pizza 4) clipping/collision 5) animaciones legibles 6) separación de iconos/HUD 7) riesgo performance 8) licencias.
Máximo 5 fallos priorizados BLOCKER/MAJOR/MINOR. No declares FPS o import probado desde una imagen fija. Pedí sólo pruebas que faltan.
```

## D. GPT — construir sistema UI de lobby
```text
Art Bible y PLAYER_JOURNEY_UI_V04.md son obligatorios.
Diseñá estructura de lobby con PLAY dominante, 3 tarjetas SHOP/LOADOUT/DAILY y monedas pequeñas. Definí tokens y estados, un layout móvil 19.5:9 + tablet 4:3 + desktop 16:9, safe areas Roblox, foco gamepad, targets táctiles, animaciones <=200ms y iconos.
No más de un CTA principal. Entrega jerarquía Roblox de componentes y brief para Claude, no solo una imagen. Todas las compras en mock están INACTIVAS hasta autorización.
```

## E. Claude Code — convertir UI a componentes
```text
Repo Defend the Pizza. Leé art bible, tokens, PLAYER_JOURNEY_UI_V04.md, AGENTS y política Git.
Implementá solo un componente reutilizable DTPButton en Luau nativo, con estilos Primary/Secondary/Danger, estados default/hover/pressed/disabled/loading, Scale y safe areas, keyboard/gamepad/touch y QA de UI real en Studio si conectado. Mantener UI existente y evitar librerías de terceros. Documentá API, instancias creadas y captura verificada; si no hay Studio, reportar QA pendiente. No abrir prompts Roblox Purchase ni vincular productos.
```

## F. Gorro de chef interno vs UGC Marketplace (NO subir)
```text
Diseñá gorro de chef original DTP-3D-005, estilo toy-food, con pizza miniatura de 3 colores, forma reconocible y textura básica. Primero solo un cosmético de la experiencia con asset propio y licencia documentada. Un eventual UGC externo requiere otro brief: avatar attachment correcto, validación Roblox, condiciones y tarifas actuales, autorización del dueño. No publicar Marketplace ni afirmar publicación gratuita.
```
