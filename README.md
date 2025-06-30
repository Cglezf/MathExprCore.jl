# MathExprCore

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Cglezf.github.io/MathExprCore.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Cglezf.github.io/MathExprCore.jl/dev/)
[![Build Status](https://github.com/Cglezf/MathExprCore.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Cglezf/MathExprCore.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Cglezf/MathExprCore.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Cglezf/MathExprCore.jl)

Un motor de computación simbólica en Julia, diseñado para la manipulación y simplificación de expresiones matemáticas.

## Descripción

`MathExprCore.jl` proporciona un conjunto de herramientas para construir, analizar y simplificar expresiones matemáticas de forma simbólica. Define una estructura de árbol de expresión (AST) y ofrece funciones para realizar operaciones como simplificación algebraica, combinación de términos semejantes y derivación simbólica.

## Estado Actual del Proyecto

Este paquete se encuentra en una **fase activa de desarrollo** (~85% completado). La API principal está establecida y las funcionalidades clave están implementadas y probadas. Sin embargo, la API puede estar sujeta a cambios menores en futuras versiones.

## Características Implementadas

* **Simplificación de Productos:** Combina factores numéricos, normaliza signos y reordena términos
* **Combinación de Términos Semejantes:** Identifica y agrupa términos aditivos con la misma parte variable
* **Derivación Simbólica:** Calcula derivadas aplicando reglas como la regla de la potencia y la cadena
* **Simplificación General:** Aplica identidades matemáticas para reducir expresiones a formas canónicas

## Uso Básico

```julia
using MathExprCore

# Definir variables simbólicas
x = var(:x)
y = var(:y)

# Crear y simplificar expresiones
expr = sin(x) * const_val(-3) * (x^2) * const_val(2) * cos(y)
simplified = simplify(expr)
# Resultado: const_val(-6) * cos(y) * sin(x) * (x ^ 2)

# Derivación simbólica
deriv = derive(x^10 + sin(x^5), :x) |> simplify
# Resultado: 10 * (x ^ 9) + (5 * (x ^ 4)) * cos(x ^ 5)
```

## Instalación

```julia
using Pkg
Pkg.add(url="https://github.com/Cglezf/MathExprCore.jl")
```

## Pruebas

```julia
using Pkg
Pkg.test("MathExprCore")
```

## Trabajo Futuro

* [ ] **Integración simbólica** básica para funciones polinomiales y trigonométricas
* [ ] **Factorización** de expresiones polinomiales y racionales
* [ ] **Expansión algebraica** completa de productos y potencias
* [ ] **Evaluación numérica** eficiente de expresiones simbólicas
* [ ] **Optimización de performance** para expresiones grandes
* [ ] **Soporte extendido** para funciones especiales (logaritmos, exponenciales)
* [ ] **Sistema de sustitución** avanzado de variables y subexpresiones
* [ ] **Compatibilidad** con otros paquetes de computación simbólica

## Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue antes de hacer cambios significativos.

## Licencia

MIT License
