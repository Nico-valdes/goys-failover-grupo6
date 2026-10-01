# GOYS — Failover Routing: La Red que no se Cae
## Laboratorio Integrador de Alta Disponibilidad y Resiliencia (Grupo 6)

**Cátedra:** Gestión Operativa y Seguridad en Redes (GOYS)  
**Institución:** Universidad Tecnológica Nacional — Facultad Regional La Plata (UTN FR La Plata)  
**Ciclo Lectivo:** 2026  
**Estado del Proyecto:** `Fase F0 — Diseño y Gestión de Cambio` (Aprobada / Completada)

---

## 📋 Resumen Ejecutivo del Laboratorio

El presente proyecto implementa una arquitectura de red empresarial jerárquica de 5 capas sobre **MikroTik RouterOS (Cloud Hosted Router - CHR)** virtualizada en **GNS3**, concebida bajo la premisa de **alta disponibilidad integral y tolerancia a fallos (*failover*)**.

A diferencia de los esquemas convencionales de red donde la disponibilidad se asume de manera pasiva, aquí la resiliencia es diseñada y asegurada en cada nivel del plano de control y de datos:

```
                  ┌─────────────────────────────────────────┐
[INTERNET]        │       ISP-1 (AS 65001)   ISP-2 (AS 65002)│
                  └────────────────────┬────────────────────┘
                                       │ eBGP Multi-homing (TCP-MD5)
                  ┌────────────────────┴────────────────────┐
[EDGE]            │                  EDGE                   │
                  └────────────┬───────────────┬────────────┘
                               │               │
                  ┌────────────┴───────────────┴────────────┐
[CORE]            │      CORE-1 ◄──OSPF Area 0──► CORE-2    │
                  └────────────┬───────────────┬────────────┘
                               │   (core-core) │
                  ┌────────────┴───────────────┴────────────┐
[DISTRIBUTION]    │    DIST-1 ◄────VRRP vrid 10,20────► DIST-2│
                  └────────────┬───────────────┬────────────┘
                               │               │
                  ┌────────────┴───────────────┴────────────┐
[ACCESS]          │     SW-ACC-USERS           SW-ACC-SERVERS│
                  │        │                           │     │
                  │     PC-USER                   SRV (Host) │
                  └─────────────────────────────────────────┘
```

### Mecanismos de Redundancia por Capa:
1. **Capa de Acceso / Primer Salto (FHRP):** Implementación de **VRRP (RFC 5798)** en los routers de distribución (`DIST-1` y `DIST-2`) con *load-sharing* simétrico activo/activo (VRID 10 como gateway principal para `USERS` en `DIST-1`, y VRID 20 como gateway principal para `SERVERS` en `DIST-2`).
2. **Capa de Core / Tránsito IGP:** Enrutamiento dinámico mediante **OSPFv2 (RFC 2328)** en Área 0 Backbone con enlace inter-core dedicado (`CORE-1 ↔ CORE-2`), eliminando *Single Points of Failure* (SPOF) y permitiendo reconvergencia sub-segundo frente a caídas de enlaces ascendentes.
3. **Capa de Borde / Conectividad Externa (Inter-AS):** Multi-homing hacia dos proveedores de tránsito diferenciados (`ISP-1` e `ISP-2`) mediante sesiones **eBGP (RFC 4271)** con políticas de selección de ruta basadas en *Local Preference* / *AS-Path* y failover automático ante cortes de upstream.
4. **Seguridad y Hardening Operativo:** Autenticación criptográfica en todos los protocolos de enrutamiento (OSPF MD5, BGP TCP-MD5, VRRP auth), deshabilitación de servicios inseguros y principio de mínimo privilegio en el control de acceso (usuario `monitor` y `admin` restringido).
5. **Gestión de Cambio y Operaciones:** Trazabilidad estricta mediante *Conventional Commits*, inventario IPAM riguroso sin solapamiento (*zero overlapping*), control de versiones de configuraciones RouterOS y procedimientos formales de backup/restore (`/export`).

---

## 👥 Integrantes y Distribución de Roles

Para garantizar la cobertura integral de las responsabilidades técnicas, operativas y de aseguramiento exigidas por la cátedra, los 5 roles formales (`R1` a `R5`) han sido distribuidos equilibradamente entre los 4 integrantes del Grupo 6:

| Integrante | Rol Principal | Rol Secundario / Compartido | Responsabilidades Clave |
| :--- | :--- | :--- | :--- |
| **Nicolás Valdés** | **R1** — Líder de Proyecto / Edge & WAN | — | Coordinación general, arquitectura eBGP en `EDGE`, control de cambios y revisión de PRs. |
| **Ivan Vijandi** | **R2** — Proveedores (ISPs / BGP externo) | **R5** — Operaciones / Backlog (Co-responsable) | Configuración de `ISP-1` e `ISP-2`, peering BGP, seguimiento del backlog y auditoría de commits. |
| **Facundo Otero** | **R3** — Core & Tránsito IGP | **R5** — QA & Verificación (Co-responsable) | Topología OSPF Área 0, enlace core-core, validación de métricas y pruebas de reconvergencia. |
| **Franco Pietrantuono**| **R4** — Distribución & FHRP | — | Configuración de `DIST-1` y `DIST-2`, grupos VRRP 10 y 20, load-sharing y acceso L2. |

### Detalle de Responsabilidades por Rol:
- **`[R1]` Líder / Edge-WAN:** Configuración de router `EDGE`, peering multi-homing eBGP, filtros de firewall y gobernanza del repositorio.
- **`[R2]` Proveedores (ISPs):** Simulación de sistemas autónomos externos (AS 65001 y AS 65002), anuncio de prefijos hacia `EDGE`, y soporte a la gestión operativa.
- **`[R3]` Core:** Enrutamiento interno OSPFv2 backbone, dimensionamiento de métricas de enlace, enlace troncal `CORE-1 ↔ CORE-2` y validación de tablas FIB/RIB.
- **`[R4]` Distribución:** Resiliencia de primer salto, sincronización VRRP vrid 10 y 20, timers de preemption y enlaces L3 hacia el Core.
- **`[R5]` Hosts / QA / Operación:** Configuración de clientes finales (`PC-USER`, `SRV`), diseño de runbooks de contingencia, ejecución de los 5 drills de failover y control de calidad de la entrega.

---

## 📂 Estructura del Repositorio

```text
goys-failover-grupo6/
├── README.md               # Portada, resumen técnico y distribución de roles
├── backlog.md              # Plan de trabajo, seguimiento de épicas (F0-F5) y tareas
├── docs/
│   ├── memoria.md          # Memoria técnica oficial del laboratorio (F0 a F5)
│   └── diagramas/          # Diagramas arquitectónicos, topología GNS3 y capturas L2/L3
├── configs/                # Scripts de configuración RouterOS (.rsc) por nodo
│   ├── isp1.rsc
│   ├── isp2.rsc
│   ├── edge.rsc
│   ├── core1.rsc
│   ├── core2.rsc
│   ├── dist1.rsc
│   └── dist2.rsc
├── backups/                # Respaldos de configuración (/export y /system backup)
├── capturas/               # Evidencias de conectividad, Wireshark y drills de falla
└── runbooks/               # Guías paso a paso para la ejecución de drills y contingencias
```

---

## 🚀 Fases del Laboratorio (Roadmap)

| Fase | Hito / Descripción | Vencimiento | Estado |
| :---: | :--- | :---: | :---: |
| **F0** | **Diseño y Gestión de Cambio:** IPAM, corrección de diagrama, seguridad y backlog | **02/10/2026** | **Completado (Aprobado)** |
| **F1** | **Topología y Hardening:** Despliegue de 7 CHR, cableado, snapshots base y hardening inicial | 09/10/2026 | Pendiente |
| **F2** | **Convergencia Interna:** Despliegue de VRRP (load-sharing) y OSPF Área 0 con MD5 | 16/10/2026 | Pendiente |
| **F3** | **Borde y Resiliencia Externa:** eBGP multi-homing con TCP-MD5 y firewall en EDGE | 16/10/2026 | Pendiente |
| **F4** | **Drills de Contingencia:** Ejecución de los 5 escenarios de falla, telemetría y runbooks | 20/10/2026 | Pendiente |
| **F5** | **Memoria Técnica y Defensa:** Cierre documental, evidencias finales y coloquio oral | 23/10/2026 | Pendiente |

---

## 🛠️ Tecnologías y Requisitos de Simulación

- **Emulador de Red:** GNS3 v2.2+ (Local Server o GNS3 VM en VMware/VirtualBox).
- **Sistema Operativo de Red:** MikroTik RouterOS v7.x / v6.x (CHR - Cloud Hosted Router, plantilla QEMU de 256 MB RAM por nodo).
- **Terminales / Clientes:** VPCS o Alpine Linux containers livianos para `PC-USER` y `SRV`.
- **Captura y Análisis:** Wireshark integrado con GNS3 para inspección de paquetes OSPF, BGP y VRRP.
