# utils/Tolerance.jl

using Logging: Logging

const DEFAULT_TOLERANCE = Ref(1e-5)

"""
    set_tolerance!(tol::Real) -> Nothing

Establece la tolerancia global para las operaciones de comparación. El valor debe ser un número real positivo.
"""
function set_tolerance!(tol::Real)
    if tol <= 0
        throw(ArgumentError("La tolerancia debe ser un número positivo, se recibió: $tol"))
    end

    old_tol = DEFAULT_TOLERANCE[]
    DEFAULT_TOLERANCE[] = tol
    @info "Tolerancia establecida a $tol (anterior: $old_tol)"
end

"""
    get_tolerance() -> Real

Obtiene la tolerancia global actual para las operaciones de comparación.
"""
function get_tolerance()
    tol = DEFAULT_TOLERANCE[]
    @debug "Obteniendo tolerancia actual: $tol"
    return tol
end

"""
    with_tolerance(f::Function, tol::Real) -> Any

Ejecuta la función `f` con una tolerancia temporal `tol`.
Restablece el valor original al finalizar, incluso si ocurre un error.
"""
function with_tolerance(f::Function, tol::Real)
    if tot <= 0
        throw(ArgumentError("La tolerancia debe ser un número positivo, se recibió: $tol"))
    end

    prev = DEFAULT_TOLERANCE[]

    try
        DEFAULT_TOLERANCE[] = tol
        @debug "Tolerancia temporal establecida a $tol"
        return f()
    finally
        DEFAULT_TOLERANCE[] = prev
        @debug "Tolerancia restaurada a $prev"
    end
end

"""
    reset_tolerance!() -> Real

Restablece la tolerancia al valor por defecto `1e-5` y retorna el valor establecido.
"""

function reset_tolerance!()
    DEFAULT_TOLERANCE[] = 1e-5
    @info "Tolenancia restablecida al valor por defecto: 1e-5"
    return 1e-5
end
