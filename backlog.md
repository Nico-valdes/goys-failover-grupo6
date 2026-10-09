# Backlog — Laboratorio Failover Routing

> Repositorio oficial del **Grupo 6** · **Materia:** Gestión Operativa y Seguridad en Redes (GOYS) · **Vencimiento final:** viernes 23/10/2026

## Leyenda de estado

- `[ ]` pendiente · `[~]` en curso · `[x]` hecho  
- Cada tarea lleva su **dueño** formal (rol asignado): `[R1]` … `[R5]`.  
- **"Hecho" = criterio de aceptación cumplido** (ver especificación oficial, sección 6). No "más o menos".

---

## Epic F0 — Diseño y gestión de cambio · *vence vie 02/10*

### IPAM / direccionamiento
- [x] [R1] [R3] Diseñar tabla de direccionamiento completa y estricta sin solapamiento (*zero overlapping*): enlaces P2P en `/30` y LANs en `/24`.
- [x] [R3] Definir asignación de IPs de Loopback y Router-IDs canónicos para toda la infraestructura CHR.
- [x] [R4] Parametrizar grupos VRRP (VRID 10 para USERS en DIST-1 y VRID 20 para SERVERS en DIST-2) para esquema activo/activo.

### Corrección del diagrama (≥ 3 defectos)
- [x] [R3] Analizar el diagrama "Enterprise Network Design" y corregir la ausencia del enlace troncal core-core (`CORE-1 ↔ CORE-2`).
- [x] [R4] Reubicar el mecanismo FHRP desde el Core hacia la capa de Distribución, liberando al Core como tránsito puro.
- [x] [R1] Subsanar el solapamiento y repetición de subredes mediante un plan IPAM jerárquico y normalizado.
- [x] [R5] Redactar la justificación técnica de ingeniería de las 3 correcciones estructurales en `docs/memoria.md`.

### Política de seguridad
- [x] [R1] [R5] Definir política de RBAC: remoción de credenciales default, creación de administrador nombrado y usuario de auditoría `monitor` (read-only).
- [x] [R1] [R5] Establecer lista taxativa de servicios inseguros a deshabilitar en los 7 routers CHR (telnet, ftp, www, api).
- [x] [R1] [R3] [R4] Definir estándares y passwords para la autenticación criptográfica en OSPFv2 (MD5), BGP (TCP-MD5) y VRRP.

### Política de operación (change log + backup)
- [x] [R5] Definir estándar de change log y convención de mensajes bajo *Conventional Commits* (`feat`, `fix`, `docs`, `ops`, `chore`).
- [x] [R5] [R1] Establecer política formal de respaldo periódico de configuraciones mediante `/export` (auditable) y `.backup` (disaster recovery).

### Repositorio git
- [x] [R1] Inicializar repositorio Git y crear el árbol de directorios estándar (`configs/`, `docs/`, `backups/`, `capturas/`, `runbooks/`).
- [x] [R1] [R5] Publicar `README.md` con resumen ejecutivo, arquitectura de 5 capas y matriz de roles R1-R5.
- [x] [R5] Consolidar `backlog.md` con trazabilidad completa de Epics F0 a F5 y asignación de responsables.

---

## Epic F1 — Topología + hardening + backup · *vence vie 09/10*

### Despliegue (7 CHR + 2 switches + 2 hosts)
- [x] [R1] [R2] [R3] [R4] Crear proyecto en GNS3 y desplegar los 7 nodos MikroTik CHR cableados según la topología de 5 capas.
- [x] [R5] Conectar switches L2 de acceso y hosts finales (`PC-USER`, `SRV`).

### IPs de enlace + loopbacks
- [x] [R2] Configurar direccionamiento IP en interfaces WAN de `ISP-1`, `ISP-2` y `EDGE`.
- [x] [R1] [R3] Configurar direccionamiento IP en enlaces P2P `EDGE ↔ CORE` y enlace inter-core `CORE-1 ↔ CORE-2`.
- [x] [R3] [R4] Configurar direccionamiento IP en enlaces de distribución `CORE ↔ DIST` y loopbacks de gestión.
- [x] [R4] [R5] Configurar interfaces LAN en `DIST-1` y `DIST-2`, y setear direccionamiento en `PC-USER` y `SRV`.

### Snapshot BASE
- [x] [R5] Generar snapshot inicial del proyecto en GNS3 denominado `BASE` con la red cableada y con direccionamiento verificado.

### Hardening (los 7 routers)
- [x] [R1] [R2] [R3] [R4] Aplicar cambio de contraseña de `admin`, creación del usuario `monitor` y deshabilitar servicios innecesarios en los 7 CHR.
- [x] [R5] Verificar bloqueo de puertos inseguros mediante escaneo/sondeo de servicios.

### Backup inicial (`/export`)
- [x] [R5] Ejecutar `/export compact` y `/system backup save` en los 7 routers y versionar los archivos en `backups/`.

---

## Epic F2 — VRRP + OSPF · *vence vie 16/10*

### VRRP (2 grupos, load-sharing, auth)
- [ ] [R4] Configurar VRRP vrid 10 en `DIST-1` (Master, priority 150) y `DIST-2` (Backup, priority 100) para subred USERS.
- [ ] [R4] Configurar VRRP vrid 20 en `DIST-2` (Master, priority 150) y `DIST-1` (Backup, priority 100) para subred SERVERS.
- [ ] [R4] Configurar autenticación y preemption en ambos grupos VRRP.
- [ ] [R5] Verificar estados Master/Backup y respuesta de VIPs con `/interface vrrp print`.

### OSPF área 0 (con MD5, incluido core–core)
- [ ] [R3] Configurar proceso OSPFv2 en `CORE-1` y `CORE-2` con Router-IDs canónicos y autenticación MD5.
- [ ] [R1] [R3] Levantar adyacencias OSPF entre `EDGE` y ambos routers Core.
- [ ] [R3] Levantar adyacencia OSPF en el enlace troncal `CORE-1 ↔ CORE-2`.
- [ ] [R3] [R4] Extender OSPF hacia `DIST-1` y `DIST-2`, declarando redes de tránsito y pasivas.
- [ ] [R5] Validar formación de adyacencias Full con `/routing ospf neighbor print`.

### Verificación L3 (ping intra-LAN + gateway virtual)
- [ ] [R5] Verificar ping desde `PC-USER` y `SRV` hacia sus respectivos gateways virtuales VRRP.
- [ ] [R5] Verificar conectividad inter-VLAN entre `PC-USER` y `SRV` a través de la capa de distribución.

---

## Epic F3 — BGP + firewall · *vence vie 16/10*

### eBGP multi-homing (2 sesiones, TCP-MD5)
- [ ] [R2] Configurar AS 65001 en `ISP-1` y AS 65002 en `ISP-2` con anuncios de rutas simuladas hacia Internet.
- [ ] [R1] Configurar AS 65000 en `EDGE` y levantar sesiones eBGP con `ISP-1` e `ISP-2` con autenticación TCP-MD5.
- [ ] [R1] Establecer política de salida (Local-Preference) priorizando ISP-1 como enlace primario e ISP-2 como backup.

### Redistribución OSPF→BGP y ruta por defecto
- [ ] [R1] Inyectar ruta por defecto aprendida por BGP hacia el dominio interno OSPF Área 0.
- [ ] [R1] Redistribuir prefijos internos hacia los ISPs según políticas de anuncio autorizadas.

### Salida a "Internet" (host → loopback ISP)
- [ ] [R5] Ejecutar traceroute desde `PC-USER` y `SRV` hacia las loopbacks de `ISP-1` e `ISP-2`.
- [ ] [R5] Comprobar simetría y resolución de saltos a través del camino primario `EDGE ↔ ISP-1`.

### Firewall edge (filtro + plano de gestión)
- [ ] [R1] Configurar reglas de firewall en `EDGE` (cadena input: drop de tráfico no autorizado en WAN, accept established/related).
- [ ] [R1] Proteger el plano de control y limitar acceso administrativo por interfaces externas.

---

## Epic F4 — Drills + monitoreo · *vence mar 20/10*

### Los 5 drills (runbook + post-mortem + tiempo)
- [ ] [R4] [R5] **Drill 1 (VRRP):** Apagar `DIST-1` y medir tiempo de convergencia de tráfico de `USERS` conmutando a `DIST-2`.
- [ ] [R3] [R5] **Drill 2 (OSPF):** Deshabilitar enlace `EDGE ↔ CORE-1` y registrar reconvergencia OSPF a través de `CORE-2` y core-core.
- [ ] [R1] [R2] [R5] **Drill 3 (BGP):** Cortar enlace con `ISP-1` y validar conmutación automática de la default route hacia `ISP-2`.
- [ ] [R1] [R5] **Drill 4 (check-gateway):** Simular falla de enlace estático con gateway tracking y verificar conmutación por distancia administrativa.
- [ ] [R4] [R5] **Drill 5 (Load-sharing VRRP):** Comprobar flujo concurrente de tráfico saliente de `USERS` vía `DIST-1` y de `SERVERS` vía `DIST-2`.
- [ ] [R5] Redactar runbooks y fichas post-mortem de cada drill en `runbooks/` y `docs/memoria.md`.

### Monitoreo (SNMP/chequeos)
- [ ] [R5] Configurar comunidad SNMP en los routers y habilitar scripts de telemetría/chequeo de estado.

### Verificación de seguridad (clave incorrecta falla)
- [ ] [R3] [R5] Configurar deliberadamente password incorrecta en un vecino OSPF y evidenciar caída de adyacencia.
- [ ] [R1] [R5] Configurar clave TCP-MD5 errónea en BGP y documentar rechazo de sesión en logs.
- [ ] [R4] [R5] Validar rechazo de anuncios VRRP con clave incorrecta.

---

## Epic F5 — Memoria + defensa · *vence vie 23/10*

### Memoria (plantilla completa)
- [ ] [R1] [R2] [R3] [R4] [R5] Consolidar configuraciones finales, evidencias, tablas de enrutamiento y conclusiones en `docs/memoria.md`.

### Backlog cerrado (todo en "hecho")
- [ ] [R5] Auditar cumplimiento de criterios de aceptación de cada tarea y pasar estado a `[x]`.

### Defensa oral (parte propia + ajena)
- [ ] [R1] [R2] [R3] [R4] [R5] Realizar simulacro de defensa grupal garantizando que cada miembro domine tanto su capa como las capas adyacentes.