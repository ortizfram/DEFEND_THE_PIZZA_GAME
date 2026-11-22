# WORK_CREDIT_EFFICIENCY — Regla permanente para GPT Work y agentes RBLX
**Creado:** 2026-11-22. **Pedido del propietario:** minimizar consumo de créditos sin sacrificar pruebas esenciales ni seguridad.

## Regla central
**Una sesión = una meta concreta y comprobable.** No reabrir todo el juego, no hacer investigación general ni añadir otros objetivos espontáneamente. Antes de empezar leer sólo AGENTS.md, este archivo, docs/SYNC_POLICY.md (si habrá cambios) y **los 2–5 archivos de la tarea**. Evitar releer documentos completos cuando un diff, grep o líneas relevantes alcanzan; comprobar siempre que el estado/versión sea actual.

## Presupuesto de operaciones, no un gasto garantizado
1. **Descubrimiento mínimo**: identificar rama/HEAD y estado, Place si se va a tocar Studio; limitar lectura inicial a contexto estrictamente relacionado. No listar 100 archivos ni recorrer todo el vault.
2. **Un plan breve**: máximo 3 acciones necesarias y criterio de éxito. Si hay riesgo de modificar otro Place/branch, detenerse antes de editar.
3. **Una implementación mínima**: aplicar el cambio preciso con diff chico. No rediseñar UI, mapa, backend o economía si sólo se pidió un ajuste físico.
4. **Pruebas enfocadas**: una validación estática y una ejecución relevante (más regresión de seguridad imprescindible). Primero la prueba más rápida. Compilar/CI si se cambió Luau. No abrir múltiples simulaciones por curiosidad; 2 clientes únicamente si la sincronización es el objetivo o podría romperse.
5. **Evitar bucles**: después de una falla, diagnosticar antes de reintentar. No repetir idéntica prueba/instalación/búsqueda sin cambiar la hipótesis. Si el bloqueo es externo (no hay Studio, permisos o entorno), entregar lo logrado y pasos exactos pendientes en lugar de gastar créditos dando vueltas.
6. **Uso de navegador / Cloud Browser**: sólo cuando la tarea exige datos actuales o interacción visual; GitHub connector/CLI para código, sin visitar el mismo contenido en navegador. Si Studio está conectado, controlar solo ese Place verificado.
7. **Pedir intervención humana sólo si es necesaria**: auth, acceso o decisión destructiva/comercial, nunca por pasos rutinarios seguros. No prometer trabajo en segundo plano.
8. **Sin herramientas caras por defecto**: no generar imágenes, videos, renders, modelos extra, grandes informes o investigaciones extensas si no son necesarios para la meta. No instalar dependencias no verificadas.
9. **Guardar progreso incremental**: una nota corta de qué se modificó, pruebas, limitaciones y siguiente paso. No volcar logs enormes al contexto: aportar rutas/errores resumidos.
10. **Sincronizar**: cuando haya cambios autorizados, actualizar sólo docs realmente afectados + CHANGELOG si aplica, un commit lógico, push/lectura de HEAD remota (según SYNC_POLICY). No hacer force-push, no sobrescribir cambios de otros agentes ni guardar archivos temporales.

## Criterio de STOP
Parar una vez cumplidos los criterios del usuario + pruebas necesarias + push verificado. No continuar «mejorando» por iniciativa propia. Si aparecen más de dos errores inesperados distintos o bloqueo que requiere otra investigación grande, registrar el resultado PARCIAL y explicar la siguiente tarea con alcance concreto, salvo que la corrección crítica sea necesaria para no dejar el proyecto inseguro o inutilizable.

## Formato final de respuesta (compacto)
- **HECHO:** qué cambió, 1–3 frases.
- **PROBADO:** pruebas realizadas realmente / pendientes; CI ≠ Roblox Studio físico.
- **GITHUB:** hash y remoto confirmado, o NO SINCRONIZADO + causa.
- **SIGUIENTE:** sólo una tarea específica, no roadmap entero.

## Aplicación inmediata: P0 V0.6
Si la solicitud es validar ragdoll/swing/3 mordidas: leer `docs/COMBAT_TUNING_PVZ_V06.md`, `src/server/Bootstrap.server.luau`, `src/server/MunchieRagdoll.luau`, `src/server/Munchie.luau`, `src/shared/Config.luau`, `tests/munchie.luau` y el fragmento client relacionado. El código está en GitHub y compila (CI verificado); **la prueba pendiente es Studio física**. Prioridad: tres mordidas por porción, primer/segundo golpe, estabilidad ragdoll y sincronización servidor. No hacer más assets, tiendas, mapas ni investigación PvZ en esa sesión.

**Alcance:** esta norma se aplica a sesiones futuras **cuando los agentes lean el repositorio**. No cambia automáticamente las cuotas de OpenAI, no ejecuta trabajos sin sesión ni puede imponer instrucciones a chats que no leen este archivo.
