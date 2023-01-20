struct OperatorPower{F <: Field} <: OperatorSym
    operator::Operator{F}
    adjoint::Bool # Redundant to copy from operator but useful for OperatorProducts 
    power::Int

    function OperatorPower(x::Operator{F} , y::Int) where F <: Field
        y == 1 && return x
        x == one(Operator) && return x
        y == 0 ? 1 : new{F}(x, x.adjoint, y)
    end
end

OporPower = Union{Operator,OperatorPower}
begin "TermInterface"
    function istree(x::OperatorPower)
        #println("OperatorPower: Istree called on $x")
        return true
    end

    function exprhead(x::OperatorPower)
        #println("OperatorPower: Exprhead called on $x")
        return :call
    end

    function operation(x::OperatorPower)
        #println("OperatorPower: Operation called on $x")
        return OperatorPower
    end

    function arguments(x::OperatorPower)
        #println("OperatorPower: Arguments called on $x")
        return [x.operator, x.power]
        # Typed tuple
    end

    function metadata(x::OperatorPower)
        #println("OperatorPower: Metadata called on $x")
        return nothing
    end

    function similarterm(t::OperatorPower, f, args, symtype; metadata=nothing)
        #println("OperatorPower: similar term called with $f, $args, $symtype, $metadata, $exprhead")
        return f(args...)
    end

end
function Base.show(io::IO, s::OperatorPower)
    print(io, "$(s.operator)^$(s.power)")
end

function Base.show(io::IO, ::MIME"text/latex", s::OperatorPower)
    print(io, "{$(s.operator)}^$(s.power)")
end

function Base.:(==)(x::OperatorPower, y::OperatorPower)
    return isequal(x.operator, y.operator) && isequal(x.power, y.power)
end

function *(x::Operator, y::OperatorPower)
    if x == one(Operator)
        return y
    else
        return x == y.operator ? OperatorPower(x, y.power + 1) : OperatorProduct(Vector{OporPower}([x, y]))
    end
end

function *(x::OperatorPower, y::Operator)
    if y == one(Operator)
        return x
    else
        return x.operator == y ? OperatorPower(y, x.power + 1) : OperatorProduct(Vector{OporPower}([x, y]))
    end
end
    
*(x::OperatorPower, y::OperatorPower) = x.operator == y.operator ? OperatorPower(x.operator, x.power + y.power) : OperatorProduct(Vector{OporPower}([x, y]))

^(x::OperatorPower, y::Int) = OperatorPower(x.operator, x.power * y)


function Base.hash(x::OperatorPower, h::UInt=UInt(0))
    h = Base.hash(string(x.operator), h)
    h = Base.hash(string(x.power), h)
    return h
end