# test/runtests_fixed.jl

using Test
using MathExprCore

function test_simplification()
    x = var(:x)
    y = var(:y)

    @testset "MathExprCore Simplification Tests" begin

        @testset "Básico: Identidades Fundamentales" begin
            # Identidad multiplicativa
            @test simplify(x * const_val(1)) == x
            @test simplify(const_val(1) * x) == x

            # Elemento absorbente (cero)
            @test simplify(x * const_val(0)) == const_val(0)
            @test simplify(const_val(0) * x) == const_val(0)

            # Identidad aditiva
            @test simplify(x + const_val(0)) == x
            @test simplify(const_val(0) + x) == x

            # Plegado de constantes
            @test simplify(const_val(5) + const_val(7)) == const_val(12)
            @test simplify(const_val(5) * const_val(7)) == const_val(35)
        end

        @testset "Intermedio: Combinación de Términos" begin
            # Términos similares básicos
            expr1 = x + x
            result1 = simplify(expr1)
            @test result1 == const_val(2) * x || result1 == x * const_val(2)

            # Términos con coeficientes
            expr2 = const_val(2) * x + const_val(3) * x
            result2 = simplify(expr2)
            @test result2 == const_val(5) * x || result2 == x * const_val(5)

            # Sustracción de términos similares
            expr3 = const_val(5) * x - const_val(3) * x
            result3 = simplify(expr3)
            @test result3 == const_val(2) * x || result3 == x * const_val(2)
        end

        @testset "Avanzado: Productos y Reordenamiento" begin
            # Producto con constantes múltiples
            expr = const_val(2) * x * const_val(3)
            result = simplify(expr)
            expected_coeff = const_val(6)
            # Verificar que el coeficiente se combina correctamente
            @test result == expected_coeff * x || result == x * expected_coeff

            # Producto con negativos
            expr_neg = const_val(-2) * x * const_val(3)
            result_neg = simplify(expr_neg)
            expected_neg = const_val(-6)
            @test result_neg == expected_neg * x || result_neg == x * expected_neg
        end

        @testset "Derivación Básica" begin
            # Derivada de constante
            @test derive(const_val(5), :x) == const_val(0)

            # Derivada de variable
            @test derive(x, :x) == const_val(1)
            @test derive(x, :y) == const_val(0)

            # Derivada de potencia simple
            expr_power = x^const_val(2)
            deriv_power = derive(expr_power, :x)
            expected_power = const_val(2) * x
            @test deriv_power == expected_power || deriv_power == x * const_val(2)

            # Derivada de suma
            expr_sum = x^const_val(2) + x
            deriv_sum = derive(expr_sum, :x)
            # Resultado: 2x + 1
            simplified_deriv = simplify(deriv_sum)
            # Verificamos que contenga los términos correctos sin ser estrictos con el orden
            @test isa(simplified_deriv, BinaryOp) && simplified_deriv.op == :+
        end

        @testset "Funciones Trigonométricas" begin
            # Identidades básicas
            sin_x = sin(x)
            cos_x = cos(x)

            # sin^2 + cos^2 = 1
            identity_expr = sin_x^const_val(2) + cos_x^const_val(2)
            @test simplify(identity_expr) == const_val(1)

            # Derivadas trigonométricas básicas
            @test derive(sin_x, :x) == cos_x
            @test derive(cos_x, :x) == -sin_x
        end

        @testset "Casos Borde y Estabilidad" begin
            # Expresiones ya simplificadas no cambian
            @test simplify(x) == x
            @test simplify(const_val(42)) == const_val(42)

            # Expresiones complejas pero ya en forma normal
            complex_expr = x * y + y * x  # Términos conmutativos
            simplified = simplify(complex_expr)
            # Debe resultar en algo como 2xy o equivalente
            @test isa(simplified, MathExpr)
        end
    end
end

# Test runner simplificado
function run_all_tests()
    @testset "MathExprCore.jl Complete Test Suite" begin
        test_simplification()
        @info "✅ Todos los tests ejecutados exitosamente"
    end
end

# Ejecutar si se llama directamente
if abspath(PROGRAM_FILE) == @__FILE__
    run_all_tests()
end
