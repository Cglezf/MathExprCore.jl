# src/operations.jl

"""
    evaluate(expr::MathExpr, bindings::Dict{Symbol, <:Number})

Evalúa numéricamente una expresión matemática con valores dados para las variables.

Ejemplo:
    expr = @expr x^2 + 2*x + 1
    result = evaluate(expr, Dict(:x => 3.0))  # → 16.0
"""
evaluate(v::Variable, bindings::Dict{Symbol,<:Number}) = bindings[v.name]
evaluate(c::NumericConstant, bindings::Dict{Symbol,<:Number}) = c.value

function evaluate(s::SymbolicConstant, bindings::Dict{Symbol,<:Number})
    if s.symbol == :π
        return π
    elseif s.symbol == :e
        return ℯ
    else
        throw(ArgumentError("Cannot evaluate symbolic constant: $s"))
    end
end

function evaluate(b::BinaryOp, bindings::Dict{Symbol,<:Number})
    lhs_val = evaluate(b.lhs, bindings)
    rhs_val = evaluate(b.rhs, bindings)

    operations = Dict(:+ => +, :- => -, :* => *,
        :/ => /, :^ => ^)

    if haskey(operations, b.op)
        return operations[b.op](lhs_val, rhs_val)
    else
        throw(ArgumentError("Unsupported binary operation: $b.op"))
    end
end

function evaluate(f::FunctionCall, bindings::Dict{Symbol,<:Number})
    arg_vals = [evaluate(arg, bindings) for arg in f.args]
    functions = Dict(:sin => sin, :cos => cos, :tan => tan, :exp => exp, :log => log, :sqrt => sqrt, :abs => abs)

    if haskey(functions, f.fn)
        return functions[f.fn](arg_vals[1])
    else
        throw(ArgumentError("Unsupported function call: $f.fn"))
    end
end
