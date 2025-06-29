# src/constructors.jl

# === Constantes predefinidas ===
const π_expr = SymbolicConstant(:π)
const e_expr = SymbolicConstant(:e)
const i_expr = SymbolicConstant(:i)
const inf_expr = SymbolicConstant(:inf)

# === Constructores por conveniencia ===
"""
    var(name::Symbol, constraints...)

Create a mathematical variable with optional constraints.
"""
function var(name::Symbol, constraints...)
    constraint_set = Set(Symbol[constraints...])
    return Variable(name, constraint_set)
end

var(name::Symbol) = Variable(name, Set{Symbol}())

function const_val(value::Number, type_info::Symbol=:auto)
    return NumericConstant(value, type_info)
end

function const_val(value::Symbol, type_info::Symbol=:transcendental)
    return SymbolicConstant(value, type_info)
end

# === Sobrecarga de operadores Binarios ===
"""
Sobrecarga de operadores binarios para MathExpr.
Permite escribir: x + y en lugar de BinaryOp(:+, x, y)
"""

for op in [:+, :-, :*, :/, :^]
    @eval begin
        function Base.$(op)(lhs::MathExpr, rhs::MathExpr)
            return smart_binary_op($(QuoteNode(op)), lhs, rhs)
        end
        function Base.$(op)(lhs::MathExpr, rhs::Number)
            return smart_binary_op($(QuoteNode(op)), lhs, const_val(rhs))
        end
        function Base.$(op)(lhs::Number, rhs::MathExpr)
            return smart_binary_op($(QuoteNode(op)), const_val(lhs), rhs)
        end
    end
end

# === Sobrecarga de operadores Unarios ===
"""
Sobrecarga de operadores unarios para MathExpr.
Permite escribir: -x, +x, abs(x), sqrt(x)
"""

function Base.:-(expr::MathExpr)
    return UnaryOp(:-, expr, false)
end

function Base.:+(expr::MathExpr)
    return expr # +x = x, identidad matemática
end

for op in [:abs, :sqrt, :conj, :real, :imag]
    @eval Base.$(op)(expr::MathExpr) = UnaryOp($(QuoteNode(op)), expr, false)
end

factorial_expr(expr::MathExpr) = UnaryOp(:!, expr, false)

# === Sobrecarga de funciones matemáticas ===
# Funciones matemáticas con dominio

for fn in [:sin, :cos, :tan, :log, :exp, :sinh, :cosh, :tanh]
    @eval Base.$(fn)(expr::MathExpr) = FunctionCall($(QuoteNode(fn)), MathExpr[expr])
end

# === MACRO @expr ===
"""
Macro para crear expresiones matemáticas con sintaxis natural.
"""

function parse_math_expr(ex)
    if ex isa Symbol
        if ex in [:π, :e, :i, :inf]
            return :(SymbolicConstant($(QuoteNode(ex))))
        else
            return :(var($(QuoteNode(ex))))
        end
    elseif ex isa Number
        return :(const_val($ex))
    elseif ex isa Expr && ex.head == :call
        op = ex.args[1]
        if op in [:+, :-, :*, :/, :^] && length(ex.args) >= 3   # >= en lugar de ==
            if length(ex.args) == 3
                lhs = parse_math_expr(ex.args[2])
                rhs = parse_math_expr(ex.args[3])
                return :(BinaryOp($(QuoteNode(op)), $lhs, $rhs, false))
            else
                result = parse_math_expr(ex.args[2])
                for i in 3:length(ex.args)
                    rhs = parse_math_expr(ex.args[i])
                    result = :(BinaryOp($(QuoteNode(op)), $result, $rhs, false))
                end
                return result
            end
        elseif op in [:sin, :cos, :tan, :log, :exp, :sqrt, :abs] && length(ex.args) == 2
            arg = parse_math_expr(ex.args[2])
            return :(FunctionCall($(QuoteNode(op)), MathExpr[$arg]))
        elseif op in [:-, :+] && length(ex.args) == 2
            arg = parse_math_expr(ex.args[2])
            return :(UnaryOp($(QuoteNode(op)), $arg, false))
        else
            error("Unsupported function or operation: $op")
        end
    else
        error("Unsupported expression type: $ex")
    end
end

macro expr(ex)
    return esc(parse_math_expr(ex))
end
