#!/usr/bin/env julia
# dev/profile_allocations.jl

using Profile
using Pkg
Pkg.activate(".")

println("💾 Analizando allocaciones de memoria...\n")

function profile_allocations()
    println("Configurar funciones específicas del módulo para profiling")

    # Template para análisis de allocaciones:
    # 1. Profile.clear_malloc_data()
    # 2. Ejecutar función varias veces
    # 3. Profile.print_malloc_data()

    println("✅ Análisis de allocaciones completado")
end

function memory_benchmark(func, args...; iterations=1000)
    # Warmup
    func(args...)

    # Medir allocaciones
    stats = @timed for _ in 1:iterations
        func(args...)
    end

    println("Tiempo total: $(stats.time*1000) ms")
    println("Allocaciones: $(stats.bytes) bytes")
    println("GC time: $(stats.gctime*1000) ms")

    return stats
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    profile_allocations()
end

profile_allocations()
