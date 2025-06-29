#!/usr/bin/env julia

"""
format_files.jl – Formatea archivos .jl recursivamente con BlueStyle
"""

using JuliaFormatter
using Logging

function format_julia_files_recursive(root_dir::String)
    @info "Formateando archivos .jl recursivamente desde: $root_dir"

    # Excluir directorios que no queremos formatear
    exclude_dirs = [".git", "node_modules", "__pycache__", ".julia", "_output"]
    julia_files_found = 0

    for (root, dirs, files) in walkdir(root_dir)
        # Filtrar directorios excluidos
        filter!(d -> !(d in exclude_dirs), dirs)

        julia_files = filter(f -> endswith(f, ".jl"), files)

        if !isempty(julia_files)
            relative_path = relpath(root, root_dir)
            @info "Formateando en: $(relative_path == "." ? "raíz" : relative_path)"

            for file in julia_files
                filepath = joinpath(root, file)
                try
                    format_file(filepath; style=BlueStyle(), verbose=false)
                    julia_files_found += 1
                    @debug "Formateado: $(relpath(filepath, root_dir))"
                catch e
                    @warn "Error formateando $(relpath(filepath, root_dir)): $e"
                end
            end
        end
    end

    @info "✅ Formateo completado - $julia_files_found archivos procesados"
end

function main()
    project_root = dirname(@__DIR__)
    format_julia_files_recursive(project_root)
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    main()
end

main()
