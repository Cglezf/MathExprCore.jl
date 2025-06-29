# src/simplification.jl - Simplificación inteligente de expresiones

"""
Simplificación automática de expresiones matemáticas usando reglas algebraicas.
"""
function smart_binary_op(op::Symbol, lhs::MathExpr, rhs::MathExpr)
    if lhs isa NumericConstant && rhs isa NumericConstant
        if op == :+
            return const_val(lhs.value + rhs.value)
        elseif op == :-
            return const_val(lhs.value - rhs.value)
        elseif op == :*
            return const_val(lhs.value * rhs.value)
        elseif op == :/ && rhs.value != 0
            return const_val(lhs.value / rhs.value)
        elseif op == :^
            return const_val(lhs.value^rhs.value)
        end
    end

    if op == :^
        if is_one(rhs)
            return lhs
        elseif is_zero(rhs)
            return const_val(1)
        elseif is_one(lhs)
            return const_val(1)
        end
    end

    if op == :+ && is_zero(rhs)
        return lhs
    elseif op == :+ && is_zero(lhs)
        return rhs
    elseif op == :* && is_one(rhs)
        return lhs
    elseif op == :* && is_one(lhs)
        return rhs
    elseif op == :* && (is_zero(lhs) || is_zero(rhs))
        return const_val(0)
    else
        return BinaryOp(op, lhs, rhs, false)
    end
end

# Funciones auxiliares para simplificación
is_zero(expr::NumericConstant) = expr.value == 0
is_zero(::MathExpr) = false
is_one(expr::NumericConstant) = expr.value == 1
is_one(::MathExpr) = false

# Métodos de simplificación específicos
simplify(v::Variable) = v
simplify(c::NumericConstant) = c
simplify(s::SymbolicConstant) = s

function simplify(expr::BinaryOp)
    if expr.simplified
        return expr
    end
    simp_lhs = simplify(expr.lhs)
    simp_rhs = simplify(expr.rhs)

    basic_result = smart_binary_op(expr.op, simp_lhs, simp_rhs)

    if !(basic_result isa BinaryOp)
        return basic_result
    end

    if basic_result.op == :+ && is_negative_term(basic_result.rhs)
        positive_term = make_positive(basic_result.rhs)
        basic_result = BinaryOp(:-, basic_result.lhs, positive_term, false)
    end

    if basic_result.op == :*
        product_result = simplify_product(basic_result)
        final_processed_product = simplify(product_result)
        if final_processed_product isa BinaryOp
            return simplify_advanced(final_processed_product)
        else
            return final_processed_product
        end
    else
        return simplify_advanced(basic_result)
    end
end

function simplify(u::UnaryOp)
    if u.simplified
        return u
    end
    simp_operand = simplify(u.operand)
    if u.op == :+
        return simp_operand
    end
    if simp_operand isa NumericConstant
        if u.op == :-
            return const_val(-simp_operand.value)
        elseif u.op == :abs
            return const_val(abs(simp_operand.value))
        elseif u.op == :sqrt && simp_operand.value >= 0
            return const_val(sqrt(simp_operand.value))
        end
    end
    if u.op == :- && simp_operand isa UnaryOp &&
       simp_operand.op == :-
        return simp_operand.operand
    elseif u.op == :abs && simp_operand isa UnaryOp &&
           simp_operand.op == :abs
        return simp_operand
    end
    return UnaryOp(u.op, simp_operand, true)
end

function simplify(f::FunctionCall)
    simplified_args = MathExpr[simplify(arg) for arg in f.args]
    if length(simplified_args) == 1 && simplified_args[1] isa NumericConstant
        val = simplified_args[1].value
        if f.fn == :sin && val == 0
            return const_val(0)
        elseif f.fn == :cos && val == 0
            return const_val(1)
        elseif f.fn == :tan && val == 0
            return const_val(0)
        elseif f.fn == :log && val == 1
            return const_val(0)
        elseif f.fn == :exp && val == 0
            return const_val(1)
        elseif f.fn == :abs
            return const_val(abs(val))
        elseif f.fn == :sqrt && val >= 0
            return const_val(sqrt(val))
        end
    end
    if f.fn == :sin && simplified_args[1] isa UnaryOp && simplified_args[1].op == :-
        return -FunctionCall(:sin, MathExpr[simplified_args[1].operand], f.domain)
    elseif f.fn == :cos && simplified_args[1] isa UnaryOp && simplified_args[1].op == :-
        return FunctionCall(:cos, MathExpr[simplified_args[1].operand], f.domain)
    end
    return FunctionCall(f.fn, simplified_args, f.domain)
end

"""
Simplificación avanzada de términos similares y identidades algebraicas.
"""
function simplify_advanced(expr::BinaryOp)
    if expr.op == :+ && are_similar_terms(expr.lhs, expr.rhs)
        return combine_similar_terms(expr.lhs, expr.rhs)
    end
    if expr.op == :- && expr.lhs == expr.rhs
        return const_val(0)
    end
    if expr.op == :- && are_similar_terms(expr.lhs, expr.rhs)
        return combine_similar_terms_substraction(expr.lhs, expr.rhs)
    end
    if expr.op == :+ && are_commutative_terms(expr.lhs, expr.rhs)
        return combine_commutative_terms(expr.lhs, expr.rhs)
    end

    # NUEVO: Simplificar productos mal ordenados en operandos
    simplified_expr = expr
    if expr.lhs isa BinaryOp && expr.lhs.op == :*
        simplified_lhs = simplify_product(expr.lhs)
        if simplified_lhs != expr.lhs
            simplified_expr = BinaryOp(expr.op, simplified_lhs, expr.rhs, false)
        end
    end
    if simplified_expr.rhs isa BinaryOp && simplified_expr.rhs.op == :*
        simplified_rhs = simplify_product(simplified_expr.rhs)
        if simplified_rhs != simplified_expr.rhs
            simplified_expr = BinaryOp(simplified_expr.op, simplified_expr.lhs, simplified_rhs, false)
        end
    end

    trig_result = apply_trig_identities(simplified_expr)
    if trig_result != simplified_expr
        return trig_result
    end
    if simplified_expr.op == :*
        product_result = simplify_product(simplified_expr)
        if product_result != simplified_expr
            return product_result
        end
    end
    return simplified_expr
end

function is_negative_term(expr::MathExpr)
    if expr isa UnaryOp && expr.op == :-
        return true
    elseif expr isa NumericConstant && expr.value < 0
        return true
    elseif expr isa BinaryOp && expr.op == :*
        # Buscar en todos los factores del producto
        factors = extract_factors(expr)
        for factor in factors
            if (factor isa NumericConstant && factor.value < 0) ||
               (factor isa UnaryOp && factor.op == :-)
                return true
            end
        end
    end
    return false
end

function make_positive(expr::MathExpr)
    if expr isa UnaryOp && expr.op == :-
        return expr.operand
    elseif expr isa NumericConstant && expr.value < 0
        return const_val(-expr.value)
    elseif expr isa BinaryOp && expr.op == :*
        # AGREGAR: Manejar productos con términos negativos
        factors = extract_factors(expr)
        positive_factors = MathExpr[]

        for factor in factors
            if factor isa NumericConstant && factor.value < 0
                push!(positive_factors, const_val(-factor.value))
            elseif factor isa UnaryOp && factor.op == :-
                push!(positive_factors, factor.operand)
            else
                push!(positive_factors, factor)
            end
        end
        return rebuild_product(positive_factors)
    else
        return expr
    end
end

function are_similar_terms(term1::MathExpr, term2::MathExpr)
    return get_variable_part(term1) == get_variable_part(term2)
end

function get_variable_part(expr::BinaryOp)
    if expr.op == :*
        if expr.lhs isa NumericConstant
            return get_variable_part(expr.rhs)
        elseif expr.rhs isa NumericConstant
            return get_variable_part(expr.lhs)
        else
            return expr
        end
    elseif expr.op == :^
        return expr
    else
        return expr
    end
end

get_variable_part(expr::Variable) = expr
get_variable_part(expr::MathExpr) = expr

function combine_similar_terms(term1::MathExpr, term2::MathExpr)
    coef1 = get_coefficient(term1)
    coef2 = get_coefficient(term2)
    variable_part = get_variable_part(term1)
    total_coef = coef1 + coef2

    if total_coef == 1
        return variable_part
    elseif total_coef == 0
        return const_val(0)
    else
        return const_val(total_coef) * variable_part
    end
end

get_coefficient(expr::Variable) = 1
get_coefficient(expr::MathExpr) = 1

function get_coefficient(expr::BinaryOp)
    if expr.op == :* && expr.lhs isa NumericConstant
        return expr.lhs.value
    elseif expr.op == :* && expr.rhs isa NumericConstant
        return expr.rhs.value
    else
        return 1
    end
end

function combine_similar_terms_substraction(term1::MathExpr, term2::MathExpr)
    coef1 = get_coefficient(term1)
    coef2 = get_coefficient(term2)
    variable_part = get_variable_part(term1)
    total_coef = coef1 - coef2

    if total_coef == 1
        return variable_part
    elseif total_coef == 0
        return const_val(0)
    elseif total_coef == -1
        return -variable_part
    else
        return const_val(total_coef) * variable_part
    end
end

function are_commutative_terms(term1::MathExpr, term2::MathExpr)
    return is_commutative_pair(term1, term2)
end

function is_commutative_pair(expr1::BinaryOp, expr2::BinaryOp)
    if expr1.op == :* && expr2.op == :*
        return (expr1.lhs == expr2.rhs && expr1.rhs == expr2.lhs)
    end
    return false
end

is_commutative_pair(::MathExpr, ::MathExpr) = false

function combine_commutative_terms(term1::MathExpr, term2::MathExpr)
    return const_val(2) * term1
end

"""
Aplica identidades trigonométricas fundamentales para simplificación.
"""

function apply_trig_identities(expr::BinaryOp)
    # sin^2(x) + cos^2(x) = 1
    if expr.op == :+ && is_pythagorean_identity(expr.lhs, expr.rhs)
        return const_val(1)
    end
    # cos^2(x) + sin^2(x) = 1 (orden inverso)
    if expr.op == :+ && is_pythagorean_identity(expr.rhs, expr.lhs)
        return const_val(1)
    end
    # 1 - sin^2(x) = cos^2(x)
    if expr.op == :- && is_one(expr.lhs) && is_sin_squared(expr.rhs)
        arg = get_func_arg(expr.rhs)
        return FunctionCall(:cos, MathExpr[arg]^const_val(2))
    end
    # 1 - cos^2(x) = sin^2(x)
    if expr.op == :- && is_one(expr.lhs) && is_cos_squared(expr.rhs)
        arg = get_func_arg(expr.rhs)
        return FunctionCall(:sin, MathExpr[arg])^const_val(2)
    end
    return expr
end

function is_pythagorean_identity(term1::MathExpr, term2::MathExpr)
    if is_sin_squared(term1) && is_cos_squared(term2)
        return get_func_arg(term1) == get_func_arg(term2)
    end
    if is_cos_squared(term1) && is_sin_squared(term2)
        return get_func_arg(term1) == get_func_arg(term2)
    end
    return false
end

function is_sin_squared(expr::BinaryOp)
    return (expr.op == :^ &&
            expr.rhs isa NumericConstant &&
            expr.rhs.value == 2 &&
            expr.lhs isa FunctionCall &&
            expr.lhs.fn == :sin)
end

function is_cos_squared(expr::BinaryOp)
    return (expr.op == :^ &&
            expr.rhs isa NumericConstant &&
            expr.rhs.value == 2 &&
            expr.lhs isa FunctionCall &&
            expr.lhs.fn == :cos
    )
end

function get_func_arg(expr::BinaryOp)
    if expr.op == :^ && expr.lhs isa FunctionCall
        return expr.lhs.args[1]
    end
    return nothing
end

is_sin_squared(::MathExpr) = false
is_cos_squared(::MathExpr) = false
get_func_arg(::MathExpr) = nothing

function extract_factors(expr::BinaryOp)
    if expr.op != :*
        return MathExpr[expr]
    end
    factors = MathExpr[]
    if expr.lhs isa BinaryOp && expr.lhs.op == :*
        append!(factors, extract_factors(expr.lhs))
    else
        push!(factors, expr.lhs)
    end
    if expr.rhs isa BinaryOp && expr.rhs.op == :*
        append!(factors, extract_factors(expr.rhs))
    else
        push!(factors, expr.rhs)
    end
    return factors
end

"""
Asigna prioridad para ordenamiento de factores:
1 = Constantes numéricas negativas
2 = Constantes numéricas positivas
3 = Variables simples
4 = Potencias de variables
5 = Funciones
"""
function factor_priority(expr::MathExpr)
    if expr isa NumericConstant
        return expr.value < 0 ? 1 : 2
    elseif expr isa Variable
        return 3
    elseif expr isa BinaryOp && expr.op == :^
        return 4
    elseif expr isa FunctionCall
        return 5
    elseif expr isa UnaryOp && expr.op == :-
        return 1
    else
        return 6
    end
end

"""
Reordena factores según prioridad matemática:
Numéricos → Variables → Potencias → Funciones
"""
function reorder_factors(factors::Vector{MathExpr})
    return sort(factors, by=factor_priority)
end

function rebuild_product(factors::Vector{MathExpr})
    if isempty(factors)
        return const_val(1)
    elseif length(factors) == 1
        return factors[1]
    else
        result = factors[1]
        for factor_index in 2:length(factors)
            result = BinaryOp(:*, result, factors[factor_index], true)
        end
        return result
    end
end

function combine_all_numeric_factors(factors::Vector{MathExpr})
    numeric_product = 1
    non_numeric_factors = MathExpr[]

    # Separar numéricos de no-numéricos
    for factor in factors
        if factor isa NumericConstant
            numeric_product *= factor.value
        else
            push!(non_numeric_factors, factor)
        end
    end

    # Reconstruir: constante combinada primero, luego el resto
    if numeric_product == 1
        return non_numeric_factors
    elseif numeric_product == 0
        return MathExpr[const_val(0)]
    else
        return vcat([const_val(numeric_product)], non_numeric_factors)
    end
end

function simplify_product(expr::BinaryOp)
    if expr.op != :*
        return expr
    end

    factors = extract_factors(expr)
    combined_factors = combine_all_numeric_factors(factors)
    ordered_factors = reorder_factors(combined_factors)
    return rebuild_product(ordered_factors)
end

extract_factors(expr::MathExpr) = MathExpr[expr]
# extract_factors(expr::UnaryOp) = MathExpr[expr]
# extract_factors(expr::Variable) = MathExpr[expr]
# extract_factors(expr::NumericConstant) = MathExpr[expr]
# extract_factors(expr::SymbolicConstant) = MathExpr[expr]
# extract_factors(expr::FunctionCall) = MathExpr[expr]
