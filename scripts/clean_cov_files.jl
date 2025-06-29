#!/usr/bin/env julia

"""
clean_cov_files.jl – Elimina archivos `.cov` recursivamente en todo el proyecto
"""

using Logging

function delete_cov_files_recursive(root_dir::String)
    @info "Limpiando archivos .cov recursivamente desde: $root_dir"
    count = 0

    for (root, dirs, files) in walkdir(root_dir)
        # Saltar directorios que no queremos procesar
        filter!(d -> !startswith(d, "."), dirs)

        for file in files
            if endswith(file, ".cov")
                filepath = joinpath(root, file)
                rm(filepath; force=true)
                count += 1
                @debug "Eliminado: $(relpath(filepath, root_dir))"
            end
        end
    end

    @info "✅ $count archivos .cov eliminados"
end

function main()
    # Desde scripts/, ir a raíz del proyecto
    project_root = dirname(@__DIR__)
    delete_cov_files_recursive(project_root)
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    main()
end

main()
