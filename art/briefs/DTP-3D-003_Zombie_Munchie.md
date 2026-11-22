# ASSET BRIEF + EVALUACIÓN — DTP-3D-003 Zombie Munchie (2 golpes)

- **ID:** DTP-3D-003 · **Nombre:** Zombie Munchie · **Gate:** P0
- **Estado:** `IN_PROGRESS` — **el propietario aprobó la variante A (2026-11-22)**. Blockouts editables reales A y B + export FBX/GLB de A con el rework aplicado. **No** hay QA_PASS: falta importar en Studio, el rig, las animaciones y la prueba en un dispositivo móvil.
- **Fecha:** 2026-11-22 · **Herramienta:** Blender 5.2.3 LTS (headless, `--factory-startup`, sin add-ons) · **Implementó:** Claude Code
- **Objetivo jugable:** enemigo común que camina hacia la pizza; el 1.er golpe lo tambalea y el 2.º lo derrota y lo lanza con física caricaturesca.
- **Primer vistazo (3 s):** "monstruito verde, gracioso y hambriento que viene por la pizza", sin miedo ni gore.
- **Derechos:** geometría 100 % procedural, generada por los scripts del repo. Sin mallas, texturas, add-ons ni herramientas pagas de terceros. Licencia `OWN_ORIGINAL`.

## Archivos reales (verificados en disco)
| Qué | A — Round | B — Noodle |
|---|---|---|
| Fuente editable | `art/source/Zombie_Munchie_A.blend` | `art/source/Zombie_Munchie_B.blend` |
| Script reproducible | `tools/asset_generation/build_munchie_a.py` | `tools/asset_generation/build_munchie_b.py` |
| Render frontal / iso | `art/renders/munchie/A_front.png`, `A_iso.png` | `art/renders/munchie/B_front.png`, `B_iso.png` |
| Estadísticas | `art/qa/Zombie_Munchie_A_stats.json` | `art/qa/Zombie_Munchie_B_stats.json` |
| Export | `art/export/Zombie_Munchie_A.fbx` + `.glb` (QA: `art/qa/Zombie_Munchie_A_export_qa.json`) | no exportado (no elegido) |

Comparativa: `art/renders/munchie/lineup_color.png`, `lineup_silhouette.png`, `lineup_100px_silhouette.png`, `lineup_100px_color.png`, `gamecam_mobile_844x390.png` (script `tools/asset_generation/render_compare.py`). **Chef, Runner, Big Eater y pizza son PROXIES grises** que solo existen en esa escena de render; no son assets.

Reconstruir todo: `powershell -ExecutionPolicy Bypass -File tools/asset_generation/run_all.ps1`.

## Convenciones técnicas (ambas variantes)
- 1 unidad Blender = 1 stud (Scene Units: Unit System **None**, según la documentación de Roblox para Blender).
- Z arriba; el personaje mira a **-Y** (vista Front de Blender). Izquierda del personaje = **+X**.
- `Zombie_Munchie_X` (Empty) es la raíz en el origen; los pies están en Z = 0.
- Cada pieza rígida tiene su **origen en su articulación** (cuello, hombro, codo, muñeca, cadera, tobillo). Los detalles (ojos, pupilas, boca, dientes, lengua, pelo, panza, babero) cuelgan de su segmento.
- Materiales: Principled BSDF de color plano, 5 por variante, colores de `art/design_tokens.json`. El verde pálido de B (`#ADDC97`) es **derivado** (60 % zombieGreen + 40 % background) y todavía no es token.
- Normales: `recalc_face_normals` aplicado a cada pieza cerrada, shading smooth, 0 aristas non-manifold y 0 caras degeneradas.

## Datos medidos
| Métrica | A — Round | B — Noodle |
|---|---|---|
| Triángulos (target interno ≤3500, no es un límite de Roblox) | **3364** | **3104** |
| Objetos de malla | 21 | 23 |
| Segmentos móviles para el rig | **12** (11 juntas + Root) | **17** (16 juntas) |
| Materiales | 5 | 5 |
| Tamaño W×D×H (studs) | 3.26 × 3.37 × **4.74** | 2.53 × 3.38 × **6.21** |
| Proxy de chef (R15 aprox. + gorro) | ~5.9 de alto | ~5.9 de alto |
| Motivo único | babero tomate (el que come), rulo de pelo | mandíbula colgante + lengua, zapatones |

## Evaluación a tamaño móvil
Pruebas hechas: un render de silueta plana a 640×256, donde A mide ≈98 px de alto, y una cámara de juego con FOV vertical de 70° (default de Roblox) a 844×390, con la pizza, el chef y los proxies del Runner y del Big Eater.

| Criterio | A — Round | B — Noodle |
|---|---|---|
| Silueta reconocible en 3 s | **Sí.** Cabeza cuadrada enorme + cuerpo de gota; legible aun como mancha. | Se lee como "flaco alto", pero a 100 px los brazos y las piernas se vuelven líneas de 2–3 px. |
| Claridad de cabeza/brazos/manos/piernas | Cabeza y manos-mitón claras; las piernas son cortas pero el par de zapatos oscuros las marca. | Cabeza y ojos muy claros; manos y antebrazos se pierden a distancia. |
| Diferenciación frente a Runner / Big Eater | **Clara.** Mide la mitad del Big Eater y es más ancho que el Runner. | **Riesgo alto:** su silueta casi coincide con el proxy del Runner (delgado, alto). |
| Rigging y animación | **Más fácil:** 10 juntas y extremidades gruesas que no se cruzan. | Más juntas (rodillas, cuello, mandíbula). Gags elásticos muy buenos, pero más trabajo. |
| Consistencia con pizza/chef/espátula | Más bajo que el chef: el chef "domina", y golpearlo y lanzarlo se ve justo y gracioso. Verde saturado que contrasta con el queso. | Más alto que el chef. El verde pálido tiene poco contraste con el queso y el piso cálido en la game-cam. |
| Triángulos | 3364 (dentro del target) | 3104 (dentro del target) |

**Recomendación de Claude: A — MUNCHIE ROUND.** Razones:
1. Es la única silueta que no se confunde con otro tipo de zombie planificado (B ≈ Runner).
2. Es más legible a 100 px y con varios zombies amontonados.
3. Su rig es bastante más simple (11 juntas contra 16), así que llega antes al test del golpe de P0.
4. La escala relativa (más bajo que el chef) refuerza la fantasía del chef pequeño pero poderoso.

**B no se elimina:** queda como base para un futuro **Runner** o una variante Noodle (sus brazos y piernas ya son "rápidos"); si se reutiliza, conviene engrosar las extremidades y saturar el verde.
**Aprobación del propietario: A APROBADA (2026-11-22).** B se conserva sin cambios.

## Rework aplicado a A tras la aprobación (2026-11-22)
Ojos +~10 %, pupilas más grandes, boca más ancha con los dientes reubicados, y piernas y pies separados (cadera ±0.62, tobillo ±0.70). Sin cambio de tris (3364) ni de altura (4.74). Renders y export regenerados.

### Sugerencias originales
1. Ojos y pupilas un 10 % más grandes y boca un poco más ancha: a 100 px la expresión se reduce a 2 puntos.
2. Sacar las piernas 0.1–0.15 studs para separarlas visualmente del torso al caminar.
3. Opcional: *palette texture* de 256 px para unir los detalles en su segmento (21 → 11 MeshParts y menos draw calls).

## Export y verificación (A)
- FBX con la configuración documentada por Roblox: solo la selección (mallas), **Forward Z, Up Y, Apply Scalings = FBX Unit Scale**, escala 1.0, sin leaf bones, sin animación, Path Mode Copy + Embed.
- GLB (glTF 2.0) con modificadores aplicados y +Y arriba.
- **Re-importados en Blender:** ambos archivos devuelven los 21 objetos, 3364 tris, el mismo tamaño 3.263 × 3.374 × 4.739, el pie en Z = 0, 0 non-manifold, 0 caras degeneradas y los 5 materiales.
- **NO verificado en Roblox Studio:** el 2026-11-22 no había ninguna instancia conectada por MCP. Falta: `File > Import 3D` en un **Baseplate nuevo**, con "Scale Unit to Stud" en el Importer, comparar contra un dummy R15 y revisar orientación, normales, colores y pivotes por MeshPart.

## Prueba en Roblox Studio (2026-11-22)
- **Place:** "Defend The Pizza" (placeId 122513508386436), modo Edit. El propietario importó `Zombie_Munchie_A.fbx` con el 3D Importer (pivote en el origen de la escena, anclado). **Claude no guardó ni publicó el Place.**
- **Geometría y escala:** 21 MeshParts y **3.26 × 4.74 × 3.37 studs**, idéntico a Blender. La convención 1 BU = 1 stud + FBX Unit Scale funciona sin reescalar. Mira a −Z (LookVector) y no está espejado: el ojo chico queda a la izquierda del personaje.
- **Escala vs avatar:** un dummy R15 mide 5.18 studs, así que el Munchie mide un **91 %** del avatar y es más ancho. Captura: `art/qa/studio/A_vs_R15_scale.jpg`.
- **Colores:** **el Importer los descartó** y todas las piezas quedaron gris por defecto. Se restauraron en Studio con los tokens por pieza (SmoothPlastic). Esa corrección vive solo en la copia del Place: para que sobreviva a una nueva importación hace falta una *palette texture* o colores de vértice en el export.
- **Ubicación:** había quedado encima del SpawnLocation; se movió a (0, 0, −14) sobre el Baseplate, mirando al spawn.
- **Rig construido** con `tools/studio/rig_munchie_a.luau`: HumanoidRootPart (caja invisible 2.4 × 2.4 × 2, anclada, colisión única) + Humanoid (HipHeight 1.15) + Animator, **12 Motor6D** (Root, Neck, Right/LeftShoulder, Elbow, Wrist, Right/LeftHip, Ankle), 9 WeldConstraints para los detalles. Las 22 piezas quedaron conectadas a la raíz y nada se desplazó (1e-7 studs). Las MeshParts tienen CanCollide=false y CanQuery=true.
- **Prueba de juntas:** se aplicó una pose de prueba (cabeza atrás, brazos y pierna) y luego se restauró la pose neutra (error 1e-7). Capturas: `art/qa/studio/A_rig_pose_test.jpg`, `A_rig_neutral.jpg`.

## Rig (plan original; construido el 2026-11-22, ver arriba)
**Tipo:** rig rígido segmentado con **Motor6D** (sin skinning). Cada segmento es un MeshPart y los detalles se sueldan a su segmento con WeldConstraint. Es la forma más barata y robusta para un NPC que recibe impulsos de física; el skinning puede venir después si el polish lo pide.

```
HumanoidRootPart (caja invisible, CanCollide=false; colisión = cápsula/caja simple)
└─ Body            [RootJoint en cadera (0, 0, 1.15)]
   ├─ Head         [Neck (0, -0.05, 2.55)]   + Eye_L/R, Pupils, Mouth, Teeth, Tongue, Hair (weld)
   ├─ Belly, Bib   (weld)
   ├─ RightUpperArm [RightShoulder] → RightLowerArm [RightElbow] → RightHand [RightWrist]
   ├─ LeftUpperArm  [LeftShoulder]  → LeftLowerArm  [LeftElbow]  → LeftHand  [LeftWrist]
   ├─ RightLeg [RightHip] → RightFoot [RightAnkle]
   └─ LeftLeg  [LeftHip]  → LeftFoot  [LeftAnkle]
```
Los pivotes ya están en las articulaciones del `.blend`. Hay que confirmar en Studio si el Importer conserva el origen de cada pieza o si hay que ajustar `PivotOffset` y los C0/C1 de cada Motor6D.

| Animación | Duración (hipótesis) | Poses clave | Marker |
|---|---|---|---|
| Idle (loop) | 1.6 s | balanceo del cuerpo ±0.08 studs, cabeza que se ladea, brazos que flotan | — |
| Walk (loop) | 0.8 s a 10 studs/s | contoneo de pato, brazos al frente, cabeza que rebota | `Footstep` |
| PizzaBite | 0.9 s | se inclina, la cabeza baja y "ñam" | `Bite` (el servidor decide el daño) |
| AttackChef | 0.4 s telegraph + 0.3 s + 0.5 s | manos abiertas (telegraph del spec), mordisco hacia adelante, recuperación | `HitWindow` |
| HitReaction (1.er golpe) | 0.35 s | cabeza hacia atrás, torso comprimido (rodillas flexionadas), brazos arriba: tambaleo | — |
| Knockback (2.º golpe) | loop mientras vuela | brazos y piernas abiertos en estrella, giro | — |
| Defeat | 0.6 s | aterriza boca arriba, "poof"/estrellitas, despawn al pool | `Despawn` |

Las animaciones de Roblox no escalan partes; el *squash* se simula con la pose (rodillas y cuello). Si hace falta squash real, se evalúa después con un tween corto de tamaño en el cliente.

## Separación de etapas (importar la malla ≠ NPC funcional)
1. **Modelado:** HECHO como blockout (A y B).
2. **Import en Studio y escala:** HECHO (2026-11-22).
3. **Rig Motor6D:** HECHO (2026-11-22), en el Place, sin guardar por Claude.
4. **Animaciones:** PENDIENTE (Animation Editor, propiedad/permiso del creador).
5. **Scripting del servidor (P0):** PENDIENTE. Máquina de estados autoritativa: `Approach → Bite/AttackChef → Hit1 (Stagger, knockback 8 studs) → Hit2 (Launch: ApplyImpulse con dueño de red el servidor, IA desactivada, Knockback) → Defeat (al aterrizar o 1.2 s) → pool`. El cliente solo pide el golpe; el servidor valida rango, cooldown y timing, aplica el daño y registra los eventos de analítica.

## QA checklist DTP-3D-003
- [x] 2 fuentes `.blend` reales y distintas (A y B)
- [x] Scripts reproducibles, sin add-ons ni assets de terceros
- [x] Renders frontal e iso de ambas + lineup + silueta a 100 px + game-cam móvil
- [x] Tris dentro del target interno; 0 non-manifold; pies en Z = 0; nombres y pivotes organizados
- [x] Export FBX/GLB de A re-importado en Blender sin pérdidas
- [x] Aprobación del propietario: A (2026-11-22)
- [x] Import en Roblox Studio y escala vs avatar (Place del juego, 2026-11-22; colores restaurados a mano)
- [x] Rig Motor6D (12 Motor6D, probado con una pose)
- [ ] 7 animaciones
- [ ] Colores persistentes en el export (palette texture o vertex colors)
- [ ] NPC P0 con server autoritativo + analítica
- [ ] Prueba en dispositivo móvil real
