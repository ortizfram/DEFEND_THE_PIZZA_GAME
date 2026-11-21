# Game Design — Defend the Pizza!

**Core fantasy:** «Soy un chef diminuto y defiendo una pizza gigante antes de que los monstruos se la coman».

**Una acción principal:** GOLPEAR con espátula grande (tap móvil, click PC). El golpe debe sentirse bien aun sin premios.

**Loop 30 s:** llegar monstruos → repeler con golpes/knockback → salvar porciones → recompensa → mejorar → próxima ola.

**Twist propuesto (posterior a P0):** algunos enemigos roban porciones y corren hacia salida; un golpe válido permite recuperar antes de perder la porción definitivamente.

**Visual:** cocina luminosa y grande, pizza central gigante. Marcas claras de daño: 8 porciones que desaparecen, sin gore. Caricatura 3D low-poly legible en móvil.

**MVP plan:** primer test un enemigo lento (Munchie), un golpe amplio con feedback audiovisual, pizza que pierde salud y 30 s de supervivencia; después ladrón (Thief), tanque (Big Eater), mejoras y 5 olas si P0 es divertido.

**Social:** ayudar a defender; combo de knockbacks, rescatar una porción en el último segundo; que también funcione jugando solo.

**FTUE targets a validar, no resultados:** acción ≤10 s; primera recompensa ≤30 s; primer momento sorprendente ≤60 s; retry rápido.

**Thumbnail storyboard:** una pizza ocupa el centro y gran parte del cuadro; mini chef a izquierda pega a monstruo que se lleva porción a derecha; queso se estira, una porción falta. Imagen 16:9 y visualmente fiel al gameplay, no es arte final.

**Source of truth completa:** [Preproducción V0.1 en el vault](https://github.com/ortizfram/roblox-vault/blob/main/Projects/DefendThePizza/PREPRODUCTION_V01.md). No cambiar la fantasía principal sin revisar esa decisión.

## Propuesta V0.2 — los zombies pueden atacar a los chefs

Leer [COMBAT_AND_REVIVE_V02.md](COMBAT_AND_REVIVE_V02.md): zombies primariamente hacia pizza, pueden golpear jugadores que los bloquean o interceptan; chefs pueden caer DOWNED, ser levantados **gratis** por compañeros o reaparecer **gratis** en ≤12 s. Candidato futuro de revive instantáneo por Robux aún no aprobado ni implementado.

## Propuesta V0.3 — tres mapas / una acción por mapa

Leer [MAPS_AND_OBJECTIVES_V03.md](MAPS_AND_OBJECTIVES_V03.md): PIZZA SHOP (CLOSE puertas), PIZZA STREET (PUSH coches/contenedores para bloquear callejones), PIZZA FACTORY (PRESS botones para activar ventiladores). Meta inmutable SAVE THE PIZZA; golpear zombies sigue siendo central. La segunda interacción es contextual; HELP revivir compañero gratis. Diseñar lectura por símbolos, una nueva palabra por mapa; niveles de lectura de cada término aún no verificados. Nada implementado en Studio.
