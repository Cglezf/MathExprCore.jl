#!/usr/bin/env julia
# dev/performance_check.jl

using InteractiveUtils
using Logging

# Macro para capturar output de @code_warntype
macro capture_out(expr)
    quote
        old_stdout = stdout
        rd, wr = redirect_stdout()
        try
            $(esc(expr))
        finally
            redirect_stdout(old_stdout)
            close(wr)
        end
        String(read(rd))
    end
end

function check_type_stability(func, args...)
    println("📊 Analizando type stability: $(func)($(join(typeof.(args), ", ")))")

    warntype_output = @capture_out @code_warntype func(args...)

    has_warnings = occursin("::Any", warntype_output) ||
                   occursin("::Union", warntype_output) ||
                   occursin("::Core.Box", warntype_output)

    if has_warnings
        println("❌ PROBLEMAS de type stability:")
        println(warntype_output)
    else
        println("✅ Type stability OK")
    end

    return !has_warnings
end

function check_inference(func, args...)
    println("\n🧠 Verificando inferencia: $(func)($(join(typeof.(args), ", ")))")

    try
        result = @inferred func(args...)
        println("✅ Inferencia exitosa - tipo: $(typeof(result))")
        return true
    catch e
        println("❌ FALLO de inferencia: $e")
        return false
    end
end

function run_performance_checks()
    println("🚀 Iniciando verificaciones de performance...\n")

    # TODO: Configurar funciones específicas del módulo
    test_functions = []

    all_stable = true
    all_inferred = true

    for (func, args) in test_functions
        println("="^50)
        stable = check_type_stability(func, args...)
        inferred = check_inference(func, args...)

        all_stable &= stable
        all_inferred &= inferred
    end

    println("\n" * "="^50)
    println("📋 REPORTE FINAL:")
    println("✅ Type Stability: ", all_stable ? "PASS" : "FAIL")
    println("✅ Type Inference: ", all_inferred ? "PASS" : "FAIL")
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    run_performance_checks()
end

run_performance_checks()
