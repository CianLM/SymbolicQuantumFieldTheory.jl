struct OperatorPower <: OperatorSym
    operator::Operator
    adjoint::Bool # Redundant to copy from operator but useful for OperatorProducts 
    power::Int

    function OperatorPower(x::Operator, y::Int)
        y == 1 && return x
        y == 0 ? 1 : new(x, x.adjoint, y)
    end
end

function Base.show(io::IO, s::OperatorPower)
    print(io, "$(s.operator)^$(s.power)")
end

function Base.:(==)(x::OperatorPower, y::OperatorPower)
    return isequal(x.operator, y.operator) && isequal(x.power, y.power)
end

function *(x::Operator, y::OperatorPower)
    if x == I
        return y
    else
        return x == y.operator ? OperatorPower(x, y.power + 1) : OperatorProduct([x, y])
    end
end

function *(x::OperatorPower, y::Operator)
    if y == I
        return x
    else
        return x.operator == y ? OperatorPower(y, x.power + 1) : OperatorProduct([x, y])
    end
end
    
*(x::OperatorPower, y::OperatorPower) = x.operator == y.operator ? OperatorPower(x.operator, x.power + y.power) : OperatorProduct([x, y])
# More verbose function definition
# function Base.:(*)(x::OperatorPower, y::OperatorPower)
#     if x.operator == y.operator
#         return OperatorPower(x.operator, x.power + y.power)
#     else
#         return OperatorProduct([x, y])
#     end
# end
^(x::OperatorPower, y::Int) = OperatorPower(x.operator, x.power * y)

adjoint(x::OperatorPower) = OperatorPower(x.operator', x.power)

function Base.hash(x::OperatorPower, h::UInt=UInt(0))
    h = Base.hash(string(x.operator), h)
    h = Base.hash(string(x.power), h)
    return h
end