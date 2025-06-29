#!/usr/bin/env julia
# dev/debug_helpers.jl

using Logging
using InteractiveUtils
using Statistics

macro debug_vars(vars...)
    exprs = []
    for var in vars
        push!(exprs, :(@debug $(string(var)) $(esc(var))))
    end
    return Expr(:block, exprs...)
end

macro time_and_check(expr)
    quote
        @info "Ejecutando: $($(string(expr)))"
        result = @time $(esc(expr))
        @info "Resultado tipo: $(typeof(result))"
        result
    end
end

function inspect_type(obj; deep=false)
    println("🔍 Inspección de tipo:")
    println("  Tipo: $(typeof(obj))")
    println("  Supertipo: $(supertype(typeof(obj)))")

    if !isprimitivetype(typeof(obj)) && fieldcount(typeof(obj)) > 0
        println("  Campos:")
        for field in fieldnames(typeof(obj))
            value = getfield(obj, field)
            println("    $field: $(typeof(value)) = $value")
        end
    end

    if deep && isa(obj, AbstractArray)
        println("  Array info:")
        println("    Tamaño: $(size(obj))")
        println("    Eltype: $(eltype(obj))")
        println("    Ndims: $(ndims(obj))")
    end
end

function quick_benchmark(f, args...; samples=1000)
    println("⚡ Benchmark rápido:")

    # Warmup
    f(args...)

    times = Float64[]
    for _ in 1:samples
        t = @elapsed f(args...)
        push!(times, t)
    end

    println("  Mínimo: $(minimum(times)*1e6) μs")
    println("  Medio: $(mean(times)*1e6) μs")
    println("  Máximo: $(maximum(times)*1e6) μs")

    return times
end

println("🛠️  Debug helpers cargados. Usar:")
println("  @debug_vars var1 var2")
println("  @time_and_check expression")
println("  inspect_type(obj; deep=false)")
println("  quick_benchmark(func, args...)")
