# Benchmark de tokens 2026

> **Task**: TS-022 (#627) — backup + benchmark + decision (actualizado 2026-11-08: Figma eliminado).

## 1. Objetivo

Comparar los enfoques disponibles para gestionar design tokens y elegir uno
para el proyecto. Criterios: simplicidad, versionado, mantenibilidad, coste.

## 2. Comparativa

| Herramienta | Rol | Pros | Contras | Limitación |
| :-- | :-- | :-- | :-- | :-- |
| **DTCG escrito a mano** | Autoría de tokens | Cero dependencias, versionable en git, control total, sin capa visual intermedia | Requiere disciplina del dev | Ninguna técnica |
| **Style Dictionary v5** | Compilador DTCG → CSS/TS | Open source, extensible, multi-plataforma, comunidad activa | Config inicial | Ninguna |
| **CSS custom properties** | Salida runtime | Soporte nativo, cambios en vivo, sin build para temas | No tipado | — |

## 3. Benchmark DTCG base

| Base | Pros | Contras |
| :-- | :-- | :-- |
| **Made Good Designs Starter** | Estructura DTCG lista, buenas prácticas, comunidad activa | Requiere adaptación al proyecto |
| **IBM Carbon** | Maduro, completo, ejemplos reales | Más complejo, orientado a enterprise |

## 4. Videos de referencia (≤10 min)

| Tema | Video | Canal | Duración |
| :-- | :-- | :-- | :-- |
| DTCG spec | "Design Tokens Community Group — Overview" | DTCG | ~8 min |
| Style Dictionary | "Getting started with Style Dictionary" | Comunidad | ~9 min |
| Pipeline completo | "Design Tokens Workflow: DTCG → Style Dictionary → Code" | Comunidad | <10 min |

## 5. Decisión

- **Autoría**: DTCG escrito a mano (o generado por IA), sin Figma.
- **Compilador**: Style Dictionary v5 (5.8.0).
- **Salida**: CSS custom properties, consumidas por React.
- **DTCG base**: Made Good Designs Starter.
- **Ruta oficial**: `frontend/src/components/imported/`.
