#!/usr/bin/env julia

"""
Script para configurar entorno de desarrollo local
Ejecutar desde la raíz: julia scripts/setup_dev.jl
"""

using Pkg

function validate_package_exists(pkg_path::String)
    project_toml = joinpath(pkg_path, "Project.toml")
    return isdir(pkg_path) && isfile(project_toml)
end

function develop_package(pkg_path::String)
    if validate_package_exists(pkg_path)
        try
            Pkg.develop(path=pkg_path)
            println("  ✅ $pkg_path desarrollado correctamente")
            return true
        catch e
            println("  ❌ Error desarrollando $pkg_path: $e")
            return false
        end
    else
        println("  ⚠️  $pkg_path no existe o no tiene Project.toml")
        return false
    end
end

function test_package_import(pkg_name::String)
    try
        @eval using $(Symbol(pkg_name))
        println("  ✅ $pkg_name cargado correctamente")
        return true
    catch e
        println("  ❌ Error cargando $pkg_name: $e")
        return false
    end
end

function setup_development_environment()
    println("🚀 Configurando entorno de desarrollo...")

    # Verificar que estamos en la raíz del monorepo
    if !isfile("Project.toml") || !isdir("packages") || !isdir("shared")
        error("❌ Ejecutar desde la raíz del monorepo JuliaMLLearning")
    end

    success_count = 0
    total_packages = 0

    # Shared packages (primero, porque otros dependen de estos)
    shared_packages = [
        "shared/MLUtils",
        "shared/DataProcessing",
        "shared/Visualization"
    ]

    println("\n📦 Instalando shared packages...")
    for pkg in shared_packages
        total_packages += 1
        if develop_package(pkg)
            success_count += 1
        end
    end

    # Module packages
    module_packages = [
        "packages/MathExprCore",
        "packages/GeometryCalc",
        "packages/StatisticalValidation",
        "packages/OptimizationLab",
        "packages/ResearchML",
        "packages/TextAnalyticsML",
        "packages/TemporalNetworks",
        "packages/SocialNetworkAnalytics",
        "packages/AdvancedAI"
    ]

    println("\n🔧 Instalando module packages...")
    for pkg in module_packages
        total_packages += 1
        if develop_package(pkg)
            success_count += 1
        end
    end

    println("\n📊 Resumen:")
    println("  Paquetes instalados: $success_count/$total_packages")

    if success_count == total_packages
        println("✅ Entorno configurado completamente!")
    else
        println("⚠️  Entorno parcialmente configurado")
        println("💡 Los paquetes faltantes se instalarán cuando los crees")
    end

    # Test de imports (solo paquetes que existen)
    println("\n🧪 Probando imports...")

    # Test shared packages
    shared_names = ["MLUtils", "DataProcessing", "Visualization"]
    for (i, pkg_name) in enumerate(shared_names)
        if validate_package_exists(shared_packages[i])
            test_package_import(pkg_name)
        end
    end

    # Test algunos module packages (si existen)
    module_names = ["GeometryCalc", "ResearchML"]
    module_paths = ["packages/GeometryCalc", "packages/ResearchML"]
    for (i, pkg_name) in enumerate(module_names)
        if validate_package_exists(module_paths[i])
            test_package_import(pkg_name)
        end
    end

    println("\n💡 Uso: using GeometryCalc, MLUtils, ResearchML, etc.")
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    setup_development_environment()
end

setup_development_environment()
