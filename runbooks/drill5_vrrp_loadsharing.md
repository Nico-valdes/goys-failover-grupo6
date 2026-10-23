# Runbook — Drill 5: Balanceo de Carga Activo/Activo en Primer Salto (VRRP Load-Sharing)

## 1. Identificación y Objetivos
- **Código:** `DRILL-05`
- **Componente:** Capa de Distribución y Acceso / FHRP Multigrupo.
- **Protocolo:** VRRPv2 (RFC 3768), grupos 10 (`USERS`) y 20 (`SERVERS`).
- **Nodos involucrados:** `DIST-1`, `DIST-2`, `PC-USER` y `SRV`.
- **Objetivo:** Demostrar el aprovechamiento simétrico de la infraestructura de red sin equipos ociosos, validando que el tráfico saliente de `USERS` cursa a través de `DIST-1` y el de `SERVERS` a través de `DIST-2` de manera concurrente.

---

## 2. Precondiciones y Estado Nominal
1. En `DIST-1`, constatar rol de Master para Users y Backup para Servers:
   ```routeros
   /interface vrrp print
   ```
   *Debe exhibir `RM` en `vrrp10-users` (prioridad 150) y `R` en `vrrp20-servers` (prioridad 100).*
2. En `DIST-2`, constatar rol de Backup para Users y Master para Servers:
   ```routeros
   /interface vrrp print
   ```
   *Debe exhibir `R` en `vrrp10-users` (prioridad 100) y `RM` en `vrrp20-servers` (prioridad 150).*
3. Clientes configurados con sus respectivas VIPs como default gateway:
   - `PC-USER`: `192.168.10.100/24`, gateway `192.168.10.1`.
   - `SRV`: `192.168.20.100/24`, gateway `192.168.20.1`.

---

## 3. Procedimiento de Verificación de Caminos Concurrentes
1. Desde la consola de `PC-USER`, trazar la ruta hacia un destino externo:
   ```bash
   trace 1.1.1.1
   ```
   *Verificar que el Salto 1 es `192.168.10.1` (VIP procesada por el procesador e interfaces de `DIST-1`).*
2. Desde la consola del host `SRV`, trazar simultáneamente la ruta hacia el exterior:
   ```bash
   trace 1.1.1.1
   ```
   *Verificar que el Salto 1 es `192.168.20.1` (VIP procesada por el procesador e interfaces de `DIST-2`).*

---

## 4. Detección y Comportamiento Esperado
1. **Flujo de Usuarios:** `PC-USER ➔ DIST-1 ➔ CORE-1/CORE-2 ➔ EDGE ➔ ISP-1`.
2. **Flujo de Servidores:** `SRV ➔ DIST-2 ➔ CORE-2/CORE-1 ➔ EDGE ➔ ISP-1`.
3. **Distribución de carga:** Se constata que el 100% del ancho de banda y capacidad de conmutación de ambos routers de distribución se utiliza de forma balanceada y activa durante la operación cotidiana, garantizando al mismo tiempo redundancia mutua en caso de falla de cualquiera de ellos.

---

## 5. Evidencias Asociadas
- `capturas/f4/07_drill5_trace_pc.png`: Trazabilidad desde `PC-USER` confirmando primer salto en `192.168.10.1` (`DIST-1`).
- `capturas/f4/08_drill5_trace_srv.png`: Trazabilidad desde `SRV` confirmando primer salto en `192.168.20.1` (`DIST-2`).
