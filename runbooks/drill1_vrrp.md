# Runbook — Drill 1: Failover de Gateway LAN (VRRP)

## 1. Identificación y Objetivos
- **Código:** `DRILL-01`
- **Componente:** Capa de Distribución / First Hop Redundancy Protocol (FHRP).
- **Protocolo:** VRRPv2 (RFC 3768), grupos 10 (`USERS`, `192.168.10.1/24`) y 20 (`SERVERS`, `192.168.20.1/24`).
- **Nodos involucrados:** `DIST-1` (Master nominal de Users, prioridad 150) y `DIST-2` (Backup nominal de Users, prioridad 100).
- **Objetivo:** Validar que ante la falla total imprevista de `DIST-1`, `DIST-2` asuma la titularidad del grupo 10 sin intervención humana, garantizando la continuidad operativa de los clientes finales.

---

## 2. Precondiciones y Estado Inicial
1. Topología completa iniciada y enrutamiento OSPF convergido en estado `Full`.
2. En `DIST-1`, verificar estado nominal:
   ```routeros
   /interface vrrp print
   ```
   *Debe mostrar `RM` en `vrrp10-users` y `R` en `vrrp20-servers`.*
3. En `DIST-2`, verificar estado nominal:
   ```routeros
   /interface vrrp print
   ```
   *Debe mostrar `R` en `vrrp10-users` y `RM` en `vrrp20-servers`.*
4. En `PC-USER`, verificar conectividad básica contra la VIP:
   ```bash
   ping 192.168.10.1 -c 3
   ```

---

## 3. Procedimiento de Inyección de Falla
1. En la consola de `PC-USER`, iniciar un envío continuo de paquetes ICMP hacia el exterior:
   ```bash
   ping 1.1.1.1 -c 50
   ```
2. Al paquete 8-10, simular la caída catastrófica del nodo `DIST-1`:
   - En GNS3: Clic derecho sobre `DIST-1` ➔ **Stop**.
   - O alternativamente en consola de `DIST-1`: `/interface ethernet disable ether3`.

---

## 4. Detección y Comportamiento Esperado
1. **Detección:** `DIST-2` deja de recibir los paquetes *Advertisement* de VRRP (emitidos cada 1 segundo con clave `Vrrp10`).
2. **Conmutación:** Al cumplirse el temporizador de caída (*Master Down Timer* $\approx 3 \times \text{Advertisement} + \text{Skew} \approx 3.6$ s), `DIST-2` transiciona de `Backup` a `Master`.
3. **Respuesta en el plano de datos:** `DIST-2` emite un *Gratuitous ARP* (GARP) anunciando la MAC virtual `00:00:5E:00:01:0A` en el switch de acceso `SW-ACC-USERS`.
4. **Pérdida observada en `PC-USER`:** Exactamente 1 paquete perdido (`icmp_seq=10 timeout`), retomando la respuesta al paquete 11.
5. En `DIST-2`, verificar el nuevo estado de emergencia:
   ```routeros
   /interface vrrp print
   ```
   *Ambos grupos deben exhibir la bandera `RM` (Running Master).*

---

## 5. Procedimiento de Recuperación y Retorno
1. Encender nuevamente `DIST-1`:
   - En GNS3: Clic derecho sobre `DIST-1` ➔ **Start**.
2. Al bootear, `DIST-1` evalúa las prioridades (`priority=150` vs `priority=100`). Debido a `preemption-mode=yes`, `DIST-1` reasume su condición de `Master` para `vrrp10-users`.
3. `DIST-2` transiciona suavemente de vuelta a estado `Backup` (`R`) para dicho grupo sin degradación de servicio.

---

## 6. Evidencias Asociadas
- `capturas/f4/01_drill1_vrrp_ping.png`: Ráfaga ICMP en `PC-USER` evidenciando 1 único paquete perdido y restablecimiento inmediato.
- `capturas/f4/02_drill1_vrrp_dist2_master.png`: Salida de `/interface vrrp print` en `DIST-2` en estado `RM` para ambos VRIDs.
