#src/derivatives.jl

const DERIVATIVE_CACHE = Dict{Tuple{UInt,Symbol},MathExpr}()

function clear_derivative_cache!()
    empty!(DERIVATIVE_CACHE)
end

function derive_memoized(expr::MathExpr, var::Symbol)
    expr_hash = hash(expr)
    cache_key = (expr_hash, var)
    if haskey(DERIVATIVE_CACHE, cache_key)
        return DERIVATIVE_CACHE[cache_key]
    end
    result = derive(expr, var)
    DERIVATIVE_CACHE[cache_key] = result
    return result
end

"""
Derivación simbólica usando reglas del cálculo diferencial.
"""
derive(v::Variable, var::Symbol) = var == v.name ? const_val(1) : const_val(0)
derive(c::NumericConstant, var::Symbol) = const_val(0)
derive(s::SymbolicConstant, var::Symbol) = const_val(0)

function derive(b::BinaryOp, var::Symbol)
    if b.op == :+
        return derive(b.lhs, var) + derive(b.rhs, var)
    elseif b.op == :-
        return derive(b.lhs, var) - derive(b.rhs, var)
    elseif b.op == :*
        return derive(b.lhs, var) * b.rhs + b.lhs * derive(b.rhs, var)
    elseif b.op == :/
        return (derive(b.lhs, var) * b.rhs - b.lhs * derive(b.rhs, var)) / (b.rhs^2)
    elseif b.op == :^
        if b.rhs isa NumericConstant
            n = b.rhs.value
            return const_val(n) * (b.lhs^const_val(n - 1)) * derive(b.lhs, var)
        else
            throw(ArgumentError("Derivative of f(x)^g(x) not supported yet"))
        end
    end
end

const DERIVATIVE_RULES = Dict{Symbol,Function}(
    :sin => x -> FunctionCall(:cos, MathExpr[x], :auto),
    :cos => x -> UnaryOp(:-, FunctionCall(:sin, MathExpr[x], :auto)),
    :tan => x -> BinaryOp(:^, FunctionCall(:sec, MathExpr[x], :auto), const_val(2), false),
    :log => x -> BinaryOp(:/, const_val(1), x, false),
    :exp => x -> FunctionCall(:exp, MathExpr[x], :auto)
)

function derive(f::FunctionCall, var::Symbol)
    if haskey(DERIVATIVE_RULES, f.fn)
        # Regla de la cadena: f'(g(x)) * g'(x)
        inner = f.args[1]
        outer_derivative = DERIVATIVE_RULES[f.fn](inner)
        inner_derivative = derive(inner, var)
        return outer_derivative * inner_derivative
    else
        throw(ArgumentError("Derivative rule for $(f.fn) not implemented"))
    end
end
