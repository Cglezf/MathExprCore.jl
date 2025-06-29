# src/display.jl

const SUPERSCRIPTS = Dict(
    '0' => '⁰',
    '1' => '¹',
    '2' => '²',
    '3' => '³',
    '4' => '⁴',
    '5' => '⁵',
    '6' => '⁶',
    '7' => '⁷',
    '8' => '⁸',
    '9' => '⁹'
)

"""
Pretty printing para expresiones matemáticas con Unicode y notación natural.
"""

function Base.show(io::IO, v::Variable)
    print(io, string(v.name))
    if !isempty(v.constraints)
        # Subíndices para constraints
        print(io, "₍", join(v.constraints, ","), "₎")
    end
end

function Base.show(io::IO, c::NumericConstant)
    print(io, c.value)
end

function Base.show(io::IO, s::SymbolicConstant)
    print(io, string(s.symbol))
end

function to_superscript(n::Number)
    if n isa Integer && 0 <= n <= 9
        return string(SUPERSCRIPTS[string(n)[1]])
    else
        return "^($n)"
    end
end

function Base.show(io::IO, b::BinaryOp)
    show(io, b.lhs)
    if b.op == :^
        if b.rhs isa NumericConstant
            if b.rhs.value == 1
                return
            elseif b.rhs.value isa Integer && 0 <= b.rhs.value <= 0
                print(io, to_superscript(b.rhs.value))
            else
                print(io, "^")
                show(io, b.rhs)
            end
        else
            print(io, "^")
            show(io, b.rhs)
        end
    elseif b.op == :*
        if b.lhs isa NumericConstant && (b.rhs isa Variable || b.rhs isa FunctionCall)
            show(io, b.rhs)
        else
            print(io, "⋅")
            show(io, b.rhs)
        end
    else
        print(io, " ", string(b.op), " ")
        show(io, b.rhs)
    end
end

function Base.show(io::IO, u::UnaryOp)
    if u.op == :-
        print(io, "-")
        show(io, u.operand)
    elseif u.op == :abs
        print(io, "|")
        show(io, u.operand)
        print(io, "|")
    elseif u.op == :sqrt
        print(io, "√(")
        show(io, u.operand)
        print(io, ")")
    else
        print(io, string(u.op), "(")
        show(io, u.operand)
        print(io, ")")
    end
end

function Base.show(io::IO, f::FunctionCall)
    print(io, string(f.fn), "(")
    for (i, arg) in enumerate(f.args)
        if i > 1
            print(io, ", ")
        end
        show(io, arg)
    end
    print(io, ")")
end
