# Runbook — Drill 3: Failover de Upstream BGP Multi-homing

## 1. Identificación y Objetivos
- **Código:** `DRILL-03`
- **Componente:** Capa de Borde WAN / Enrutamiento Inter-AS.
- **Protocolo:** eBGP (RFC 4271), TCP-MD5 (`BgpSecret2026Edge`).
- **Nodos involucrados:** `EDGE` (AS 65000), `ISP-1` (AS 65001, primario con `local-preference 200`) e `ISP-2` (AS 65002, secundario con `local-preference 100`).
- **Objetivo:** Comprobar la conmutación dinámica de la ruta por defecto hacia el proveedor secundario ante la pérdida del enlace con el upstream principal.

---

## 2. Precondiciones y Estado Inicial
1. En `EDGE`, verificar que ambas sesiones BGP se encuentren en estado `established`:
   ```routeros
   /routing bgp session print
   ```
2. Verificar en `EDGE` que la ruta por defecto activa (`Ab`) es la provista por `ISP-1`:
   ```routeros
   /routing route print where dst-address in 0.0.0.0/0
   ```
   *Debe listar `Ab 0.0.0.0/0 via 198.51.100.1`.*

---

## 3. Procedimiento de Inyección de Falla
1. En `PC-USER`, iniciar tráfico hacia el exterior:
   ```bash
   ping 1.1.1.1 -c 50
   ```
2. Interrumpir el enlace WAN principal en `EDGE`:
   ```routeros
   /interface ethernet disable ether1
   ```
   *(O detener el nodo `ISP-1` en el entorno virtual).*

---

## 4. Detección y Comportamiento Esperado
1. **Detección:** Se interrumpe la sesión TCP en el puerto 179 y la interfaz WAN1 pasa a estado *link-down*.
2. **Conmutación BGP:**
   - La sesión con `ISP-1` pasa a estado `down`.
   - `EDGE` retira la ruta por defecto con `local-preference 200` y la marca como inalcanzable (`UbH`).
   - Se evalúa la siguiente mejor ruta en la RIB y se instala como activa en la FIB la recibida desde `ISP-2` (`203.0.113.1%ether2`) con `local-preference 100`.
3. **Comportamiento en `PC-USER`:**
   - Se observa 1 paquete de timeout (`icmp_seq=13 timeout`).
   - A partir del paquete 14, los paquetes son recibidos y procesados por el router `ISP-2` (`203.0.113.1`).
4. **Verificación en `EDGE`:**
   ```routeros
   /routing route print where dst-address in 0.0.0.0/0
   ```
   *Muestra `Ab 0.0.0.0/0 via 203.0.113.1%ether2`.*

---

## 5. Procedimiento de Recuperación y Retorno
1. Restaurar la interfaz WAN en `EDGE`:
   ```routeros
   /interface ethernet enable ether1
   ```
2. La sesión BGP se restablece con autenticación TCP-MD5. Al recibir la ruta por defecto con `local-preference 200`, `EDGE` reaplica la política y conmuta nuevamente a `ISP-1` como camino primario de manera predecible.

---

## 6. Evidencias Asociadas
- `capturas/f4/04_drill3_bgp_failover.png`: Salida de tabla de ruteo en `EDGE` con `Ab` apuntando a `203.0.113.1` (ISP-2) y `UbH` en ISP-1.
- `capturas/f4/05_drill3_bgp_ping_pc.png`: Ráfaga ICMP de `PC-USER` mostrando la conmutación y la recepción de paquetes por parte de `ISP-2` (`203.0.113.1`).
