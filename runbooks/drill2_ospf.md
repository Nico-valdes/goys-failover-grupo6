# Runbook — Drill 2: Failover de Troncal OSPF (Corte de Enlace Core)

## 1. Identificación y Objetivos
- **Código:** `DRILL-02`
- **Componente:** Capa de Core y Borde / IGP Backbone.
- **Protocolo:** OSPFv2 (RFC 2328), Área 0 (Backbone), autenticación criptográfica MD5 (`Goys2026OspfPass`).
- **Nodos involucrados:** `EDGE`, `CORE-1` y `CORE-2`.
- **Objetivo:** Demostrar la resiliencia y el cálculo de caminos alternativos del algoritmo Dijkstra (Shortest Path First - SPF) ante la interrupción súbita del enlace primario entre el router de borde `EDGE` y el núcleo `CORE-1`.

---

## 2. Precondiciones y Estado Inicial
1. Todas las adyacencias OSPF del backbone en estado `Full`:
   ```routeros
   /routing ospf neighbor print
   ```
2. En `DIST-1`, verificar que la ruta por defecto (`0.0.0.0/0`) instalada por OSPF apunta al camino primario vía `CORE-1` (`10.0.0.13%ether1`).
3. En `PC-USER`, verificar tráfico saliente continuo:
   ```bash
   ping 1.1.1.1 -c 3
   ```

---

## 3. Procedimiento de Inyección de Falla
1. En la consola de `PC-USER`, iniciar tráfico continuo:
   ```bash
   ping 1.1.1.1 -c 50
   ```
2. Al paquete 5-8, interrumpir el troncal primario en `EDGE`:
   En la consola de `EDGE`:
   ```routeros
   /interface ethernet disable ether3
   ```
   *(Corta el enlace directo `EDGE (ether3) ↔ CORE-1 (ether1)`).*

---

## 4. Detección y Comportamiento Esperado
1. **Detección:** `EDGE` y `CORE-1` registran evento `Link Down` inmediato en sus interfaces locales.
2. **Reconvergencia OSPF:** 
   - `EDGE` purga la adyacencia con `CORE-1` (`4.4.4.4`).
   - Se inunda un LSA Tipo 1 (Router LSA) informando el cambio topológico.
   - OSPF ejecuta el cómputo SPF y selecciona la ruta redundante a través de `CORE-2` (`5.5.5.5` vía `10.0.0.5%ether4`).
   - El enlace inter-core (`CORE-1 ↔ CORE-2`, red `10.0.0.8/30`) mantiene conectados a los switches de distribución sin aislamiento.
3. **Pérdida observada en `PC-USER`:** 0 paquetes perdidos (convergencia sub-segundo transparente al usuario final).

---

## 5. Procedimiento de Recuperación y Retorno
1. En la consola de `EDGE`, rehabilitar la interfaz troncal:
   ```routeros
   /interface ethernet enable ether3
   ```
2. OSPF negocia nuevamente paquetes Hello (timers 10s/40s) con autenticación MD5 y transiciona por `Init ➔ 2-Way ➔ ExStart ➔ Loading ➔ Full`.
3. El camino primario se reestablece como camino de menor costo métrico hacia `CORE-1`.

---

## 6. Evidencias Asociadas
- `capturas/f4/03_drill2_ospf_failover.png`: Terminal de `PC-USER` exhibiendo 50 paquetes consecutivos con 0% de pérdida ante la conmutación en caliente de enlaces OSPF.
