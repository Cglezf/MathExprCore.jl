# utils/CoverageConfig.jl

using Coverage
using Logging

function run_coverage()
    project_root = normpath(joinpath(@__DIR__, ".."))
    src_dir = joinpath(project_root, "src")
    test_dir = joinpath(project_root, "test")
    utils_dir = joinpath(project_root, "utils")

    try
        # Usar Base.with_logger o Logging.with_logger para evitar conflictos con el logger global
        cov = Logging.with_logger(SimpleLogger(stderr, Logging.Warn)) do
            Coverage.process_folder(src_dir)
        end

        # ✅ Guardar lcov.info en test/
        Coverage.LCOV.writefile(joinpath(test_dir, "lcov.info"), cov)
        @info "✓ lcov.info guardado correctamente en test/lcov.info"

    finally
        # 🧹 Limpieza completa de archivos *.cov en src/, test/ y utils/
        for dir in (src_dir, test_dir, utils_dir)
            if isdir(dir)
                for f in readdir(dir; join=true)
                    endswith(f, ".cov") && rm(f; force=true)
                end
            end
        end
    end
end

