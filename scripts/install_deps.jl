#!/usr/bin/env julia
# install_dependencies.jl - Script standalone para instalar dependencias

using Pkg

function install_dependencies(dependencies::Vector{String})
    println("📦 Instalando dependencias...")

    for pkg in dependencies
        try
            Pkg.add(pkg)
            println("✅ $pkg instalado")
        catch e
            println("⚠️ Error con $pkg: $e")
        end
    end

    println("⚡ Precompilando...")
    Pkg.precompile()
    println("✅ Dependencias instaladas")
end

# Uso - cambiar esta línea según el proyecto:
install_dependencies(["LinearAlgebra", "StaticArrays", "Plots"])
