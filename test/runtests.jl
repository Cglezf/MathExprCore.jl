# test/runtests.jl

# Activar logging según configuración del entorno
ENV["JULIA_DEBUG"] = "MathExprCore"

# Cargar el módulo principal
using MathExprCore
using Test

# Configuración temprana (loggers, paths, etc.)
include("../utils/LoggerConfig.jl")
init_logger()

# Utilidades
include("../utils/CoverageConfig.jl")
include("../utils/Tolerance.jl")

# Pruebas unitarias
include("simplification_test.jl")

# Ejecutar todas las pruebas agrupadas
@testset "MathExprCore.jl" begin
    test_simplification()
    @info "✅ All tests executed"
end

# Post-test: cobertura y limpieza
run_coverage()
