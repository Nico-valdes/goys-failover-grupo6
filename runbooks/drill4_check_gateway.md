# Runbook — Drill 4: Failover Estático con Gateway Tracking (`check-gateway`)

## 1. Identificación y Objetivos
- **Código:** `DRILL-04`
- **Componente:** Capa de Borde / Enrutamiento Estático con Sondeo Activo L3.
- **Mecanismo:** RouterOS `check-gateway=ping` y distancia administrativa flotante (`distance=1` primario, `distance=2` backup).
- **Nodos involucrados:** `EDGE`.
- **Objetivo:** Demostrar la capacidad de conmutación ante fallas no visibles a nivel físico (enlace UP pero gateway mudo/degradado que deja de responder tráfico ICMP).

---

## 2. Precondiciones y Configuración de Prueba
1. En `EDGE`, crear dos rutas estáticas hacia una IP de prueba (`8.8.8.8/32`), asignando tracking por ping a la primera y mayor distancia a la segunda:
   ```routeros
   /ip route
   add comment="WAN1-Primario" dst-address=8.8.8.8/32 gateway=198.51.100.1 check-gateway=ping distance=1
   add comment="WAN2-Backup" dst-address=8.8.8.8/32 gateway=203.0.113.1 distance=2
   ```
2. Verificar estado nominal antes de la falla:
   ```routeros
   /ip route print where comment~"WAN"
   ```
   *La ruta a `198.51.100.1` exhibe la bandera `As` (Active, Static). La ruta a `203.0.113.1` exhibe la bandera `s` (inactiva por mayor distancia).*

---

## 3. Procedimiento de Inyección de Falla
1. Simular la pérdida de respuesta del gateway primario sin desconectar la interfaz (emulando congelamiento del router del ISP o corte aguas arriba):
   ```routeros
   /ip firewall filter add action=drop chain=output comment="Simular-Caida-GW" dst-address=198.51.100.1 protocol=icmp place-before=0
   ```
2. Esperar 20 segundos para que transcurra el ciclo de detección (RouterOS emite sondeos ICMP cada 10 s; tras 2 pérdidas consecutivas declara el gateway inalcanzable).

---

## 4. Detección y Comportamiento Esperado
1. **Detección:** El temporizador de `check-gateway` expira tras 20 segundos de silencio.
2. **Conmutación:** 
   - La ruta primaria pasa a estado inactivo (`IsH` / Inactive, Static, HW-offloaded).
   - RouterOS promueve de forma inmediata la ruta secundaria (`distance=2`), marcándola con la bandera `As` (Active, Static).
3. **Verificación en consola:**
   ```routeros
   /ip route print where comment~"WAN"
   ```
   *Se constata la inversión de roles: ruta 1 inactiva, ruta 2 activa.*

---

## 5. Procedimiento de Recuperación y Limpieza
1. Eliminar la regla de bloqueo para rehabilitar el tráfico ICMP hacia el gateway:
   ```routeros
   /ip firewall filter remove [find comment="Simular-Caida-GW"]
   ```
2. En 10 segundos, RouterOS recibe el eco ICMP, restaura la ruta primaria a estado `As` y devuelve la ruta secundaria a estado inactivo.
3. Limpiar las rutas de prueba para preservar la higiene de la configuración:
   ```routeros
   /ip route remove [find comment~"WAN"]
   ```

---

## 6. Evidencias Asociadas
- `capturas/f4/06_drill4_check_gateway.png`: Captura integral en consola de `EDGE` mostrando el estado nominal (`As` y `s`), la inyección de la regla de filtrado y la conmutación a `IsH` y `As`.
