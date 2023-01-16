struct AbstractOperator{T <: Field}
    name::Symbol
    field::DataType

    function AbstractOperator(T::Type{<:Field},name::Symbol)
        return new{T}(name,T)
    end
end
field(::AbstractOperator{T}) where {T} = T

function Base.show(io::IO, s::AbstractOperator)
    print(io, s.name)
end

begin "TermInterface"
    function istree(x::AbstractOperator)
        println("AO is not a tree")
        return false
    end

    function similarterm(t::AbstractOperator, f, args, symtype=Operator, metadata=nothing, exprhead=exprhead(t))
        println("AO similar term called with $f, $args, $symtype, $metadata, $exprhead")
        return f(args...)
    end

end

# Made callable in Operator.jl @ ./operator.jl:10
    # i.e. returns a = AbstractOperator(ScalarField, :a)
    # :($(esc(a)) = AbstractOperator(ScalarField, Expr($(esc(a)))) )

a = AbstractOperator(ScalarField, :a)
nameof(typeof(a))
fieldnames(typeof(a))
field(a) == a.field

macro field(name)
    return quote
        abstract type $name <: Field end
    end
end
@field DiracField

macro operator(field, op)
    return :($(esc(op)) = AbstractOperator($(esc(field)), $(Expr(:quote, Symbol(string(op)))) ) )
end

macro operators(field, ops...)
    # Check each op is a unique symbol.
    [ops...] == unique(ops) || error("Duplicate operator names in @operators: $ops")
    return Expr(:block, [:( $(esc(op)) = AbstractOperator($(esc(field)), $(Expr(:quote, Symbol(string(op)))) ) ) for op in ops]...)
end