#!/usr/bin/env julia
# benchmark/run.jl

using BenchmarkTools
using Pkg
Pkg.activate("..")

# Cargar el paquete principal
using _REPO_NAME_  # Se reemplaza automáticamente

println("🚀 Ejecutando benchmarks de {{REPO_NAME}}...\n")

# Suite de benchmarks
const SUITE = BenchmarkGroup()

# TODO: Agregar benchmarks específicos del paquete
# Ejemplo para paquete geométrico:
# SUITE["geometry"] = BenchmarkGroup()
# SUITE["geometry"]["distance"] = @benchmarkable distance($p1, $p2) setup=(p1=Point2D(0,0); p2=Point2D(3,4))
# SUITE["geometry"]["area"] = @benchmarkable area($c) setup=(c=Circle(Point2D(0,0), 5.0))

# Ejecutar benchmarks
# if !isempty(SUITE)
#     results = run(SUITE, verbose=true)
#     show(results)
# else
#     println("⚠️  No hay benchmarks definidos aún")
#     println("Agregar benchmarks específicos del paquete en este archivo")
# end

println("\n✅ Benchmarks completados.\n")
