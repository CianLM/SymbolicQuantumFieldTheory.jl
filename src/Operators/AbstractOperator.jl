struct AbstractOperator
    name::Symbol
    # field::Field

    # function AbstractOperator(name::Symbol, field::Field)
    #     return new(name, field)
    # end

    function AbstractOperator(name::Symbol)
        return new(name)
    end

    # function Base.one(::Type{AbstractOperator})
    #     return AbstractOperator(:I, NonInteractingField())
    # end
end

function Base.show(io::IO, s::AbstractOperator)
    print(io, s.name)
end

begin "TermInterface"
    function istree(x::AbstractOperator)
        return false
    end

end
nameof(::AbstractOperator) = :AbstractOperator
# One can disable the above function implementation with
# delete method Base.nameof
nameof(::AbstractOperator) = :AbstractOperator

# Make callable
function (op::AbstractOperator)(index::SymbolicUtils.Sym{Number,Nothing}, adjoint::Bool=false)
    return Operator(op.name, (Symbol(index),), adjoint)
end
a = AbstractOperator(:a)
a(p)
typeof(sin(p))
SymbolicUtils.Term(q, (p-q,p))
sin(p)
