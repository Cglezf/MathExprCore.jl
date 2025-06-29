# utils/LoggerConfig.jl – configuración mínima y segura del logger

using Logging

const LOG_LEVEL_MAP = Dict{String,LogLevel}(
    "debug" => Logging.Debug,
    "info" => Logging.Info,
    "warn" => Logging.Warn,
    "error" => Logging.Error,
)

"""
    parse_log_level(level::String) -> LogLevel

Convierte un string de nivel de log a un LogLevel de Julia. Si el nivel no es reconocido, retorna `nothing`.
"""

function parse_log_level(level::String)
    return get(LOG_LEVEL_MAP, lowercase(level), nothing)
end

"""
    init_logger()

Configura un `ConsoleLogger` global si no existe uno.
El nivel se toma de `ENV["JULIA_LOG_LEVEL"]` o por defecto es `Info`.

Ejemplos de nivel válido:
- "debug"
- "info"
- "warn"
- "error"
"""
function init_logger()
    if current_logger() isa NullLogger
        level_str = get(ENV, "JULIA_LOG_LEVEL", "info")
        log_level = parse_log_level(level_str)


        if log_level === nothing
            @warn "Nivel de log desconocido '$level_str', usando `Info`"
            log_level = Logging.Info
        end

        global_logger(ConsoleLogger(stderr, log_level))

    end
end


"""
    with_logger(f; level="warn")

Ejecuta la función `f()` con un `ConsoleLogger` temporal con nivel `level`.
No afecta el logger global.

Este método se conserva como utilidad opcional.
"""
function with_logger(f::Function; level::String="warn")
    log_level = parse_log_level(level)

    if log_level === nothing
        @warn "Nivel de log desconocido '$level', usando `Warn`"
        log_level = Logging.Warn
    end

    logger = ConsoleLogger(stderr, log_level)

    return Logging.with_logger(logger) do
        f()
    end
end

"""
    available_log_levels() -> Vector{String}

Retorna una lista de los niveles de log disponibles.
"""
function available_log_levels()
    return collect(keys(LOG_LEVEL_MAP))
end
