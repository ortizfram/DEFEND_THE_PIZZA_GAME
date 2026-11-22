# Combat, Physics, Enemies & Animation — V0.4
**Fecha:** 2026-11-21  
**ESTADO:** propuestas numéricas para prototipo, NO balance validado, NO implementado.
**Antecedentes:** GAME_DESIGN.md, COMBAT_AND_REVIVE_V02.md, MAPS_AND_OBJECTIVES_V03.md, PLAYER_JOURNEY_UI_V04.md.

## 0. Un combate que un niño entienda
Los jugadores son chefs diminutos con **espátulas enormes**. El zombie quiere morder la pizza; si el chef se interpone, el zombie puede morderlo. El zombie recibe golpes exagerados que lo hacen tambalear, volar o caer, con cara de sorpresa y sonidos de caricatura. No gore, heridas realistas ni miedo extremo.

**Dos acciones esenciales:** HIT (tocar o mantener) y ACT contextual (cerrar puerta/empujar/activar ventilador/revivir aliado). No combos complicados. Moverse, orientar el personaje hacia amenaza, tocar HIT, ver enemigo retroceder. PC click/E; en móvil botones grandes. Auto-orientación suave al zombie más cercano dentro de cono al pulsar HIT si el movimiento/cámara lo necesita, con feedback y sin atacar enemigos fuera de alcance.

## 1. Stats iniciales — NO definitivos

Cada golpe ligero válido quita **1 HP de enemigo**. HP se muestra como corazones/mini barra simple solo al recibir golpe, si aporta. No usar cifras como tutorial principal. La columna golpes expresa golpes ligeros acertados sin efectos adicionales.

| Zombie | HP | Golpes ligeros | Velocidad (studs/s) | Comportamiento y reacción | Amenaza a chef | Disponible |
|---|---:|---:|---:|---|---|---|
| **Runner / zombie rápido** | 1 | **1** | 16 | Corre hacia la pizza, sale volando al primer hit | Muerde 1 corazón con telegraph `0.4 s | G2/G3, si suma |
| **Munchie / zombie común** | 2 | **2** | 10 | Camina con brazos al frente; 1er hit tambalea, 2do sale volando | Muerde 1 corazón si chef lo bloquea | P0 |
| **Slice Thief / ladrón** | 2 | **2** | 14 | Corre a pizza, toma porción y cambia a ruta de escape; 1er hit cae, porción recuperable, 2do despacha | Empujón de 1 corazón solo si bloqueado (opcional) | G2 |
| **Big Eater / tanque** | 5 | **5** | 7 | Pesado: retrocede poco en primeros golpes, 5to gran caída cómica | Golpe lento con telegraph `0.8 s, quita 1 corazón | G3 |
| **Mega Muncher / boss opcional** | 12 | **12** | 6 | Gran monstruo de Factory; 3 fases visuales según HP, empuje cada tercer golpe | Golpe circular telegrafiado `1 s, quita 1 corazón | Post MVP |

**Orden pedagógico:** solo Munchie al inicio. Runner 1 hit enseña respuesta rápida, Thief 2 hits enseña perseguir, Big Eater 5 hits enseña equipo; boss 12 hits SOLO si hay demostración de diversión. Evitar hacer enemigo invulnerable sin explicación visual.

**Dificultad:** escalar **cantidad y ritmo de spawns**, no inflar HP a 20/50. En co-op 1–6, más spawn con límites y sin paredes de zombis. Todo ajustable en Config luego del playtest. No crear todos los tipos desde el día 1.

## 2. Golpes de espátula — mismo botón HIT

| Gesto | Daño HP | Timing inicial | Física y respuesta | Quién golpea |
|---|---:|---|---|---|
| **Tap: slap rápido** | 1 | cooldown `0.55 s; conexión al marker HIT del swing | Knockback **8 studs** para Munchie/Thief (runner cae en 1). Cara "O!", splash de salsa rojo no-gore, sonido boing | 1–3 targets frente a chef |
| **Mantener HIT 0.55 s y soltar: mega slap** | 2 | carga breve `0.55 s; recovery/cooldown `1.1 s | Knockback **12 studs** a zombie normal, **3 studs** al tanque; flash de espátula y golpe de queso | máximo 4–5 targets cercanos, sujeto a QA |
| **3er tap consecutivo** | 1 | si taps válidos en ventana `1.4 s entre golpes; no botón extra | Remate automático con impulso más fuerte y giro gracioso de muñeca; **sin incrementar daño** | mismos targets que slap normal |
| **Golpe sin acertar** | 0 | mismo cooldown | whoosh breve y animación; no recompensa | ninguno |

**Meta de sensibilidad:** hitbox ancho frontal en cono `150° y alcance `7 studs, solo al pasar marker de contacto; no es arma de precisión. El cliente anticipa efecto visual; el servidor valida rango, frente, timestamps/cooldowns razonables y colisiones y calcula todo HP/coins y estado del zombie. No permitir que un cliente falsifique hit, daño, kill, velocidad o knockback. El remate de 3er tap puede resultar demasiado complejo: desactivarlo con flag de prueba si distrae.

**Important:** `studs` es longitud de mapa, no velocidad. El desplazamiento de 8/12 studs se simula con impulso controlado/fricción, **no** se teletransporta un zombie a una distancia fija que atraviese paredes. La duración de ragdoll y fuerza cambian con el peso; no disparar físicas a cámara/mundo fuera de límites. Valores se ajustarán en Studio.

## 3. Física caricaturesca, pero consistente
- **Feedback inicial al impacto:** compresión/squash durante `0.08 s, retroceso en 0.15–0.35 s, sonrisa de susto, 2–4 partículas de queso o salsa y una línea breve de movimiento. Evitar sangre.
- **Muerte de zombie:** pequeño ragdoll o caída animada de **0.45–0.8 s**, luego polvo/comida cómica y desaparecer; no dejar cuerpos simulando física durante minutos.
- **Tanque:** gran impacto visual y sonido grave, pero muy poco empuje hasta último golpe; no invulnerabilidad completa que el jugador no entienda.
- **Golpes encadenados con amigos:** el servidor combina empujes de forma acotada; permite clips sin tirar enemigo infinitamente fuera de mapa o atravesar barreras/pizza.
- **Red**: simular autoridad de golpes/health en servidor; NPCs simples con puntos de ruta server-side, sensible a network ownership (mantener control del servidor donde corresponda), limitar simulaciones físicas y número de enemigos activos. Cliente interpola animaciones/VFX, no administra HP.
- **Ragdoll opcional**: preferir animación + impulso y un control básico de caídas a ragdoll físico completo si baja FPS en móvil. Primer P0 NO necesita Constraints ragdoll.
- **Cámara:** movimiento Roblox familiar, suave; hit-stop audiovisual breve solo visual y local (`40–60 ms, probar), mínimo screen shake e interruptor Reduce Motion.
- **Contactos y daño:** zombie normal avisa ataque con manos abiertas `0.4 s y muerde si chef sigue en alcance; cooldown para zombie (`1.6 s). Cada chef tiene breve invulnerabilidad luego de recibir un golpe `0.8 s (no stunlock). Tanque avisa 0.8 s. Valores sujetos a QA.

## 4. Vida de chefs, pizza y puertas
- **Chef:** **3 corazones**; Munchie/Runner/Thief/Big Eater hacen **1 corazón** por golpe. No ataques invisibles ni instant-kill; iconos bien visibles.
- **DOWNED:** cae con animación divertida (espátula se cae cerca), no elimina al jugador del juego. Compañero ACT `2 s para HELP gratis; respawn gratuito seguro **10 s** (dentro del máximo 10–12 s propuesto), posible protección corta `1.5 s al levantarse. Si todos caen, igualmente reaparecen gratis. No reservar revive para quienes paguen. El respawn debe ser rápido en partidas de `30 s por ola.
- **Pizza:** 8 porciones visibles, una unidad de vida por porción. Munchie al alcanzarla realiza animación de mordida visible `2.5 s (interrumpible por knockback) y pierde 1 porción, con cooldown de mordida. Thief toma 1 porción y la lleva a salida; un golpe de espátula puede obligarlo a soltarla, segundo mata; solo una porción por ladrón y recuperación una sola vez.
- **Puertas, bloqueos y ventilador:** estados OPEN/CLOSED/DAMAGED/BROKEN con server authority, `2-3 golpes de zombie para romper puerta inicialmente; auto/contenedor `4 golpes; ventilador activo `4 s con cooldown `18 s como punto de prueba. Un enemigo que no puede entrar debe intentar romper la barrera, no congelarse. No permitir fortificación eterna. Los golpes de zombie a barrera son golpes temporizados, no daño por frame.
- **Derrota:** únicamente cuando toda la pizza se pierde. No acabar partida por caer todos durante 10 s si quedan porciones; se reponen gratis.

## 5. Movement & locomotion
**Chef:** WalkSpeed base `17 studs/s (Roblox default familiar 16), salto normal, aceleración no agresiva; pequeño rebote visual en pasos. Sin stamina, sprint aparte, double-jump ni dash en P0. Mantener cámara con vista de pizza y entradas sin precisar puntería milimétrica.
**Zombies:**
- Munchie: pasos desparejos y brazos delante, 10 studs/s; para al comer o morder.
- Runner: carrera con inclinación y pies veloces, 16 studs/s; telegraph en saltito antes de sprint si confunde.
- Thief: mira pizza, salta porción, se da vuelta y huye, 14 studs/s; triángulo de pizza visible en manos/sobre cabeza durante huida.
- Big Eater: barriga balanceando, grandes pisadas, 7 studs/s; telegraph gigante antes de golpe.
- Boss opcional: 6 studs/s y cambio de postura cada tramo de salud; no requerir navegación compleja.
**IA estado inicial:** Spawn → MarchToPizza → ObstacleAttack/PlayerCounterattack (breve) → PizzaBite/Steal → Escape (Thief) → Stunned/Knocked/Dead. No pathfinding continuo a todos los jugadores; repath por eventos/cambio de puerta, evitar loops de NPC atascados.

## 6. Animaciones a producir en orden
**Chef mínimo P0**: Idle (mira espátula), Run, HitLeft, HitRight, HitImpact, Hurt, Downed, GetUp. **Post P0:** HoldCharge, ChargedSlap, ComboFinish, ReviveFriend, DoorClose, PushCar, PressButton, VictoryPose, DefeatReaction.
**Zombie mínimo P0**: Walk/Shamble, PizzaBite, WindUpBite, HitReact, KnockbackFall, Exit/Disappear. **Gate 2:** ThiefCarry, ThiefTurnAndRun, SliceDrop. **Gate 3:** HeavyWindup, StaggerHeavy, BossIntro.
**Técnica Roblox:** usar `Animator` + tracks reutilizadas, markers como `HIT`, `FOOTSTEP`, `BITE`, `DROP` y `REVIVE_DONE`. Los markers sincronizan SFX/efectos, pero **no son autoridad de daño**: validar el instante lógico en servidor. Evitar crear nuevas AnimationTracks en cada golpe. Sincronizar animation priorities y probar R15/R6; decidir rig antes de producción.
**Cara y squash:** expresiones con decals/animated face o cambios visuales simples, sin decenas de rigs faciales; el monstruo debe verse sorprendido cuando recibe daño, especialmente en móvil.
**QA:** 30 FPS móvil, 1/2/6 jugadores, puerta cerrada durante knockback, zombie sobre pizza, dos hits simultáneos, downed y respawn, servidor lag, no daño doble tras muerte.

## 7. Balance y feedback por hit (especificación corta)
- Zombie común 2 hits: **1.º** gesto sorpresa/retrocede; **2.º** vuelo/caída/muere. Runner 1 hit: vuelo inmediato.
- Ladrón 2 hits: 1.º suelta porción (si llevaba), 2.º sale volando; si ya soltó no vuelve a robar de inmediato.
- Tanque 5 hits: cada impacto lo sacude y muestra muesca/partículas; 5.º caída grande, evitar invisibilidad de daño.
- Heavy 2 HP no obliga a usar un gesto diferente; **tap siempre puede ganar**.
- No colocar combo, barra de rage, daño crítico RNG, debuffs, 8 armas ni habilidades complicadas en P0.
- Equilibrar equipo mediante cantidad de zombies; XP/coins de equipo no incentivan robar último golpe.
- Cualquier valor aquí es **HIPÓTESIS**. Para pasar a implementación deben colocarse en archivo Config único, no duplicarse en scripts.

## 8. Gates de implementación
1. **P0**: un zombie común, 2 golpes, una pizza, una puerta y solo slap tap; respuesta física convincente y test móvil/PC.
2. **P1**: zombie daña chef, 3 corazones, revive gratis y UI de porciones; sin monetización.
3. **P2**: Thief roba/suelta porción, botón ACT rescates, heavy opcional; ajustes sobre datos.
4. **P3**: tank/runner, oleadas y mapas adicionales; boss y animaciones elaboradas solo si mejoran el gameplay.
5. **P4**: pulido de audio, cutscenes, cosméticos; compras únicamente tras autorización separada.

**Ningún enemigo, golpe, IA, animación o física está implementado en Roblox Studio al redactar esto.**

## Ajuste posterior de P0 — versión V0.6 (2026-11-22)

Los valores anteriores de knockback 3/7 studs y pizza mordida cada 2.5 s se sustituyen **para P0 actual** por los de [COMBAT_TUNING_PVZ_V06.md](COMBAT_TUNING_PVZ_V06.md). Nueva lógica: un solo zombie requiere tres mordidas (~una por segundo) para consumir una porción, compartidas entre zombies, impacto al punto visible, cancelación al golpearlo; espátula daña Munchie 2 hits, empuje del primero ~5 studs en el tiempo y ragdoll físico lanzado en segundo. Velocidades/TTL son hipótesis de test; no garantizan distancia final concreta.
