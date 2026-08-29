# Decisiones Técnicas y de Negocio

Este archivo registrará las decisiones técnicas, umbrales configurados y compromisos adoptados durante el desarrollo del Proyecto 1 (Bitácora sísmica CEET).

## Umbrales Configurados

- **Umbral de magnitud:** `15.0`
  - **Justificación:** Tras pruebas, el ruido basal y movimientos normales (caminar, mover el equipo) rondan los 9.8 a 12.0. Un umbral de 15.0 asegura que solo impactos bruscos registren un evento, evitando falsos positivos durante traslados.

- **Tiempo de reposo (debounce):** `900 ms`
  - **Justificación:** Un solo impacto físico genera múltiples picos de aceleración en fracciones de segundo. El reposo de 900 ms actúa como "debounce", garantizando que un golpe cree exactamente un registro en la base de datos local y no sature la red ni el servidor con eventos duplicados en un mismo choque.
