# SETUP WINDOWS — Primer Zombie Munchie editable en Blender para Roblox
**Fecha:** 2026-11-22  
**Estado:** instrucciones verificadas contra fuentes oficiales, NO instalaciones comprobadas en el PC del usuario y NO existe todavía el modelo.

## 1. Descargas para Windows (orden sugerido)
| Programa | Obligatorio para | Sitio oficial | Costo |
|---|---|---|---|
| Blender estable (Windows x64) | crear, editar, riggear y exportar Munchie (.blend/.fbx) | https://www.blender.org/download/ | gratis |
| Roblox Studio | importar, medir escala, animar/probar y convertirlo en NPC de Roblox | https://create.roblox.com/docs/studio/setup | gratis |
| Git para Windows | clonar/sincronizar este repo de código | https://git-scm.com/install/win | gratis |
| Visual Studio Code | abrir el repo y editar código Luau / scripts Blender | https://code.visualstudio.com/download | gratis |
| Claude Code (opcional si la persona desea automatizar) | escribir/iterar script de Blender y código del NPC | https://code.claude.com/docs/en/setup | instalación posible, **uso requiere cuenta/plan facturado compatible** |
| Rojo CLI + plugin Roblox Studio | sincronizar Luau entre carpetas y Studio | https://rojo.space/docs/installation/ | gratis |
| Blockbench (opcional) | bocetos muy básicos, no obligatorio si usás Blender | https://www.blockbench.net/ | gratis |

**No hace falta instalar aparte Python para scripting de Blender:** Blender tiene Python integrado. No instalar plugins de Roblox o Blender desde videos desconocidos. No necesitas Rojo para el primer mesh; sólo cuando los scripts del juego se sincronicen a Studio.

**Fuente Roblox Blender**: https://create.roblox.com/docs/art/blender
**Importer Roblox**: https://create.roblox.com/docs/studio/importer
**Rigging Roblox**: https://create.roblox.com/docs/art/modeling/rigging
**Claude Code**: https://code.claude.com/docs/en/setup
**Claude pricing**: https://claude.com/pricing

## 2. Primera instalación: Git → repositorio → VS Code
Después de instalar Git/VS Code, abrir PowerShell:

```powershell
git --version
git clone https://github.com/ortizfram/DEFEND_THE_PIZZA_GAME.git
cd DEFEND_THE_PIZZA_GAME
git status -sb
code .
```

Si `code` no se reconoce, abrir VS Code y usar **File → Open Folder**. Si Git informa que el repo ya existe, **no clonar sobre la carpeta actual**: entrar en ella y hacer `git status -sb` / `git pull --ff-only` con árbol limpio. **No utilizar el ZIP inicial de Git anterior con historial divergente.** La repo de código estaba pública al verificarse; para hacerla privada cambiar GitHub Settings con decisión del propietario.

**Claude Code (solo si cuenta habilitada)**: después de instalar Git/VS Code, PowerShell:
```powershell
winget install Anthropic.ClaudeCode
claude --version
cd DEFEND_THE_PIZZA_GAME
claude
```
Si prefieres installer oficial nativo, ver setup de Anthropic; el comando alternativo de la documentación es `irm https://claude.ai/install.ps1 | iex`. Ejecutar scripts remotos solo desde la web oficial y confiando en su origen; para minimizar riesgo se recomienda WinGet. Claude debe leer `CLAUDE.md`/`AGENTS.md` y Art Bible antes de actuar. Claude Code no es automáticamente gratuito por disponer de Blender y Studio.

**Rojo (cuando se conecte programación):** instalar CLI desde `https://rojo.space/docs/installation/`, probar `rojo --version`, instalar plugin `rojo plugin install` si la versión usada lo soporta, abrir un **Baseplate nuevo** autorizado, ejecutar `rojo serve default.project.json`, conectar plugin en Studio; no sincronizar un Place antiguo desconocido ni mezclar scripts con otro juego.

## 3. Dos siluetas concretas — diseñar y comparar ANTES de modelar versión final
**Referente común:** Toy Pizza Panic de `docs/ART_DIRECTION_AI_ASSETS_V05.md`, colores de `art/design_tokens.json`. Niño debe distinguir zombie en la cámara Roblox desde ~100 px.

### Variante A — MUNCHIE ROUND (primera candidata)
- **Silueta:** cabeza grande casi cuadrada con esquinas redondeadas + torso ancho y corto como gota + patas cortas; brazos gorditos.
- **Personalidad:** ojos muy grandes y desparejos, boca de "O" enorme, sonrisa desconcertada; verde hoja con panza menta.
- **Reacción del primer golpe:** torso se aplasta y cabeza se va hacia atrás. **Segundo golpe**: se inclina y sale volando con brazos abiertos.
- **Ventaja de producción:** muchas formas primitivas redondeadas, rig simple, buena lectura a tamaño móvil. Diferenciar del Big Eater por altura/anchura y del Runner por piernas.
- **Riesgo:** si es demasiado redondo parecerá un blob sin brazos; resaltar manos, cabeza y paso.

### Variante B — MUNCHIE NOODLE
- **Silueta:** figura delgada, cabeza alargada con mandíbula colgante, brazos larguísimos arqueados, torso estrecho, pies grandes.
- **Personalidad:** ojos saltones, balanceo como gelatina, paso descoordinado; verde pálido + acento menta.
- **Reacción del primer golpe:** giro flexible de brazos y mandíbula, 2.º golpe lo hace rodar de costado.
- **Ventaja:** animaciones cómicas.
- **Riesgo:** puede confundirse con el Runner rápido; más piezas para rig, puede ser menos legible cuando varios zombies se amontonan.

**Selección inicial recomendada:** probar ambas siluetas en gris plano desde la cámara real con chef/pizza. **A es la candidata preferida**, pero no se declarará elegida definitivamente sin ver dos capturas y hacer un test de lectura 3 segundos. B podría reservarse para otro tipo zombie.

## 4. Pasos de creación de modelo editable en Blender
1. En Blender comenzar con primitives (UV spheres/cubes bevel) y **crear DOS archivos realmente diferentes**, no dos renders del mismo mesh: `art/source/Zombie_Munchie_A.blend` y `art/source/Zombie_Munchie_B.blend`.
2. Organizar piezas por nombre y jerarquía: `Body`, `Head`, `LeftArm`, `RightArm`, `LeftLeg`, `RightLeg`, `Eyes`, `Mouth`; al modelar, medir contra referencia de avatar del juego, pivote al suelo, orientación de frente consistente.
3. Exportar una imagen frontal y una isométrica de A y B (o viewport screenshots reales), **sin inventar que un render es mesh**; comparación de silueta a ~100px y cámara de juego sobre pizza.
4. Elegir la que más se reconozca; empezar rig/animaciones sólo después de elegir. Para una malla deformable agregar Armature/Bones, pesos, importar rig con FBX; para NPC muy simple pueden usarse piezas rígidas articuladas. Decidir rig según animaciones antes de construirlo.
5. Exportar únicamente el elegido a FBX (o glTF compatible con tipo), conservar **.blend como fuente editable**. Roblox Studio **File/Avatar/3D Importer según versión actual** y validar escala, normales, UV, color y rig. Roblox advierte que FBX por defecto desde Blender puede importar a tamaño inesperado: comparar con un dummy estándar y corregir escala export.
6. Para probar un zombie que CAMINA/MUERDE/REACCIONA, necesitará rig funcional + animaciones + lógica de NPC en Roblox Studio; **importar FBX estático no lo vuelve un NPC animado automáticamente**.
7. Añadir variantes editables y capturas verificadas a Git y actualizar `art/asset_manifest.json`; no marcar QA_PASS ni APPROVED sin existir fuente/export, derechos y evidencia de QA. Probar móvil después.

## 5. Prompt exacto inicial para Claude Code (en la carpeta del repo)
```text
Actuá como artista técnico senior de Roblox/Blender. Leé AGENTS.md, CLAUDE.md,
docs/ART_DIRECTION_AI_ASSETS_V05.md, art/design_tokens.json,
art/asset_manifest.json y art/ASSET_BRIEF_TEMPLATE.md.
OBJETIVO ÚNICO: crear los dos BLOCKOUTS EDITABLES del zombie DTP-3D-003.
Variante A MUNCHIE ROUND (cuerpo ancho/corto, cabeza grande, patas cortas).
Variante B MUNCHIE NOODLE (delgado, brazos largos, pies grandes).
No hagas gameplay, tienda, animaciones finales ni cambies otros proyectos.
Verificá si Blender está instalado y se puede ejecutar. Si sí, creá con
Blender Python dos archivos .blend reales reproducibles, con mallas separadas,
materiales planos de la Art Bible, pivote al piso, nombres limpios.
Renderizá/capturá frente e isométrica por variante. No declares modelos
creados si Blender no puede ejecutarse: entregá scripts reproducibles y
reportá PARCIAL. No generes plugin ni dependencias externas sin aprobación.
Compará lectura a 100 px y triángulos. Solamente después de aprobar una
silueta, exportá FBX/glTF, chequeá importación en Studio autorizado y
decidí rig/animaciones. Actualizá manifest, QA, changelog; sincronizá en
GitHub con commit/push verificable sin force. Reportá rutas exactas y límites.
```

## 6. Checklist para dar por terminado el PRIMER Munchie
- [ ] Blender Studio instalado y abierto en Windows, sin asumir que Claude tiene control automáticamente.
- [ ] Repositorio `DEFEND_THE_PIZZA_GAME` clonado desde GitHub y abierto VS Code.
- [ ] 2 fuentes .blend existen realmente (A y B) y render/captura de ambas verificable.
- [ ] Una silueta elegida tras test a 100px; aprobación registrada en `docs/DECISIONS.md`.
- [ ] Archivo elegido exportado .fbx/.gltf e importado en Place de prueba; escala/pivote/material correctos.
- [ ] Si se desea animar: rig creado y probado; no afirmar que importar mesh es suficiente.
- [ ] Manifest tiene paths y derechos; pruebas de validación GitHub ejecutadas; commit/push confirmado.
- [ ] **NO** publicar UGC en Marketplace ni usar copyright de otros juegos. UGC comercial requiere pasos y cargos aparte.

**Las herramientas instaladas en el PC del usuario no se han verificado desde esta conversación.**
