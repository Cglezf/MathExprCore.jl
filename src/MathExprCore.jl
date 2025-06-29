# src/MathExprCore.jl

module MathExprCore

# Exporta (interfaz pública del paquete) también las herramientas de tolerancia si son parte del API
export MathExpr, Variable, FunctionCall, BinaryOp, UnaryOp, NumericConstant, SymbolicConstant
export var, const_val, smart_binary_op, evaluate, derive, simplify, simplify_product, simplify_advanced, get_variable_part, are_similar_terms, combine_similar_terms, get_coefficient, apply_trig_identities
export derive_memoized, clear_derivative_cache!, DERIVATIVE_CACHE, extract_factors, rebuild_product, normalize_signs, reorder_factors, factor_priority, combine_numeric_factors
export @expr

# Inclusión de archivos del módulo principal
include("types.jl")
include("constructors.jl")
include("simplification.jl")
include("operations.jl")
include("derivatives.jl")
include("display.jl")

# Configuración del entorno (logging, tolerancia, utilidades)
include("../utils/Tolerance.jl")
include("../utils/LoggerConfig.jl")
init_logger()

end # module
