# src/types.jl - Sistema de tipos matemáticos unificado

"""
Jerarquía de tipos para expresiones matemáticas.

La jerarquía está diseñada para ser extensible y type-stable,
permitiendo que módulos futuros añadan nuevos tipos sin modificar el core.
"""

abstract type MathExpr end
abstract type MathValue <: MathExpr end
abstract type MathOperation <: MathExpr end
abstract type MathFunction <: MathExpr end

struct Variable <: MathValue
    name::Symbol
    constraints::Set{Symbol}

    function Variable(name::Symbol, constraints::Set{Symbol})
        validate_type(constraints)
        new(name, constraints)
    end
end

Variable(name::Symbol) = Variable(name, Set{Symbol}())

struct NumericConstant <: MathValue
    value::Number
    type_info::Symbol

    function NumericConstant(value::Number, type_info::Symbol=:auto)
        if type_info == :auto
            type_info = infer_number_type(value)
        else
            validate_type(value, type_info)
        end
        new(value, type_info)
    end
end

function infer_number_type(value::Number)
    if isnan(value)
        return :undefined   # Represent NaN as undefined
    elseif isinf(value)
        return :extended_real # Include ±∞
    elseif value isa Integer
        return :integer
    elseif value isa Rational
        return :rational
    elseif value isa Real
        return :real
    elseif value isa Complex
        return :complex
    else
        return :unknown
    end
end

const VALID_CONSTRAINTS = Set([:integer, :rational, :real, :positive, :negative, :nonzero, :bounded, :even, :odd, :complex])

const NUMERIC_TYPES = Dict{Symbol,Vector{Symbol}}(
    :integer => [:integer, :rational, :real],
    :rational => [:rational, :real],
    :real => [:real],
    :complex => [:complex],
    :extended_real => [:extended_real, :real],
    :undefined => [:undefined]
)

const SYMBOLIC_CONSTANTS = Dict{Symbol,Symbol}(
    :π => :transcendental,  # Número pi
    :e => :transcendental,  # Número de Euler
    :γ => :transcendental,  # Constante de Euler-Mascheroni
    :φ => :transcendental,  # Número áureo
    :i => :complex,         # Unidad imaginaria
    :inf => :extended_real,     # Infinito positivo
    :neg_inf => :extended_real, # Infinito negativo
    :nan => :undefined      # Not a Number
)

function validate_type(constraints::Set{Symbol})
    invalid = setdiff(constraints, VALID_CONSTRAINTS)
    if !isempty(invalid)
        throw(ArgumentError("Invalid constraints: $(invalid). Valid: $(collect(VALID_CONSTRAINTS))"))
    end
end

function validate_type(value::Number, type_info::Symbol)
    inferred = infer_number_type(value)
    allowed = get(NUMERIC_TYPES, inferred, [inferred])
    if type_info ∉ allowed
        throw(ArgumentError("Type mismatch: $(value) is of type $(inferred), expected one of $(allowed)"))
    end
end

function validate_type(symbol::Symbol, type_info::Symbol)
    if symbol ∉ keys(SYMBOLIC_CONSTANTS)
        valid_symbols = collect(keys(SYMBOLIC_CONSTANTS))
        throw(ArgumentError("Unknown symbolic constant: $(symbol). Valid constants: $(valid_symbols)"))
    end
    expected = SYMBOLIC_CONSTANTS[symbol]
    if type_info != expected
        throw(ArgumentError("Type mismatch for symbolic constant $(symbol): expected $(expected), got $(type_info)"))
    end
end

struct SymbolicConstant <: MathValue
    symbol::Symbol
    type_info::Symbol

    function SymbolicConstant(symbol::Symbol, type_info::Symbol=:auto)
        if type_info == :auto
            if symbol ∉ keys(SYMBOLIC_CONSTANTS)
                valid_symbols = collect(keys(SYMBOLIC_CONSTANTS))
                throw(ArgumentError("Unknown symbolic constant: $(symbol). Valid constants: $(valid_symbols)"))
            end
            type_info = SYMBOLIC_CONSTANTS[symbol]
        else
            validate_type(symbol, type_info)
        end
        new(symbol, type_info)
    end
end

const VALID_UNARY_OPS = Set([:-, :+, :abs, :sqrt, :!, :conj, :real, :imag])

const INVOLUTIVE_OPS = Set([:-, :conj])

const IDEMPOTENT_OPS = Set([:abs, :real, :imag])

const VALID_BINARY_OPS = Set([:+, :-, :*, :/, :^, :mod, :div, :max, :min, :gcd, :lcm])

const COMMUTATIVE_OPS = Set([:+, :*, :max, :min, :gcd, :lcm])

const ASSOCIATIVE_OPS = Set([:+, :*, :max, :min, :gcd, :lcm])

const IDENTITY_ELEMENTS = Dict{Symbol,Union{Int,Symbol}}(
    :+ => 0,            # a + 0 = a
    :* => 1,            # a * 1 = a
    :max => :neg_inf,   # Negative infinity for max
    :min => :inf,       # Positive infinity for min
    :gcd => 0,          # gcd(a, 0) = |a| (técnicamente)
    :lcm => 1           # lcm(a, 1) = |a| (técnicamente)
)

const ABSORBING_ELEMENTS = Dict{Symbol,Union{Int,Symbol}}(
    :* => 0,            # a * 0 = 0
    :max => :inf,       # a max inf = inf
    :min => :neg_inf,   # a min -inf = -inf
    :gcd => :inf,       # GCD with infinity is infinity
    :lcm => 0           # LCM with zero is zero
)

struct BinaryOp <: MathOperation
    op::Symbol
    lhs::MathExpr
    rhs::MathExpr
    simplified::Bool

    function BinaryOp(op::Symbol, lhs::MathExpr, rhs::MathExpr, simplified::Bool=false)
        validate_type(op, Val{:binary})
        new(op, lhs, rhs, simplified)
    end
end

function validate_type(op::Symbol, ::Type{Val{:binary}})
    if op ∉ VALID_BINARY_OPS
        valid_ops = collect(VALID_BINARY_OPS)
        throw(ArgumentError("Invalid binary operation: $(op). Valid operations: $(valid_ops)"))
    end
end

function validate_type(op::Symbol, ::Type{Val{:unary}})
    if op ∉ VALID_UNARY_OPS
        valid_ops = collect(VALID_UNARY_OPS)
        throw(ArgumentError("Invalid unary operation: $(op). Valid operations: $(valid_ops)"))
    end
end

struct UnaryOp <: MathOperation
    op::Symbol
    operand::MathExpr
    simplified::Bool

    function UnaryOp(op::Symbol, operand::MathExpr, simplified::Bool=false)
        validate_type(op, Val{:unary})
        new(op, operand, simplified)
    end
end

const FUNCTION_DOMAINS = Dict{Symbol,Set{Symbol}}(
    :log => Set([:positive]),
    :sqrt => Set([:nonnegative]),
    :asin => Set([:bounded]),
    :sin => Set([:real]),
    :cos => Set([:real]),
    :tan => Set([:real]),
    :exp => Set([:real]),
    :abs => Set([:all]),
)

struct FunctionCall <: MathFunction
    fn::Symbol
    args::Vector{MathExpr}
    domain::Set{Symbol}

    function FunctionCall(fn::Symbol, args::Vector{MathExpr}, domain::Set{Symbol})
        if isempty(args)
            throw(ArgumentError("Function calls must have at least one argument."))
        end
        new(fn, args, domain)
    end
end

function FunctionCall(fn::Symbol, args::Vector{MathExpr}, domain_strategy::Symbol)
    actual_domain = if domain_strategy == :auto
        get(FUNCTION_DOMAINS, fn, Set([:all]))
    else
        throw(ArgumentError("Unsupported domain strategy symbol: $(domain_strategy). Valid strategies: `:auto` or provide a `Set{Symbol}` directly."))
    end
    return FunctionCall(fn, args, actual_domain)
end

FunctionCall(fn::Symbol, args::Vector{MathExpr}) = FunctionCall(fn, args, :auto)

function Base.:(==)(a::Variable, b::Variable)
    return a.name == b.name && a.constraints == b.constraints
end

function Base.:(==)(a::NumericConstant, b::NumericConstant)
    return a.value == b.value && a.type_info == b.type_info
end

function Base.:(==)(a::BinaryOp, b::BinaryOp)
    return a.op == b.op && a.lhs == b.lhs && a.rhs == b.rhs
end

function Base.:(==)(a::UnaryOp, b::UnaryOp)
    return a.op == b.op && a.operand == b.operand
end

function Base.:(==)(a::FunctionCall, b::FunctionCall)
    return a.fn == b.fn && a.args == b.args && a.domain == b.domain
end

function Base.:(==)(a::SymbolicConstant, b::SymbolicConstant)
    return a.symbol == b.symbol && a.type_info == b.type_info
end

Base.hash(v::Variable, h::UInt) = hash((v.name, v.constraints), h)
Base.hash(c::NumericConstant, h::UInt) = hash((c.value, c.type_info), h)
Base.hash(b::BinaryOp, h::UInt) = hash((b.op, b.lhs, b.rhs), h)
Base.hash(u::UnaryOp, h::UInt) = hash((u.op, u.operand), h)
Base.hash(f::FunctionCall, h::UInt) = hash((f.fn, f.args, f.domain), h)
Base.hash(s::SymbolicConstant, h::UInt) = hash((s.symbol, s.type_info), h)
