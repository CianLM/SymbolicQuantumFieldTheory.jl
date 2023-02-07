struct AbstractOperator{T<:Field}
    name::Symbol
    field::DataType

    function AbstractOperator(T::Type{<:Field}, name::Symbol)
        return new{T}(name, T)
    end
end
field(::AbstractOperator{T}) where {T} = T

function Base.show(io::IO, s::AbstractOperator)
    print(io, s.name)
end

begin
    "TermInterface"
    function istree(x::AbstractOperator)
        # println("AO is not a tree")
        return false
    end

    function similarterm(t::AbstractOperator, f, args, symtype=Operator, metadata=nothing, exprhead=exprhead(t))
        # println("AO similar term called with $f, $args, $symtype, $metadata, $exprhead")
        return f(args...)
    end

end

# Made callable in Operator.jl @ ./operator.jl:10
# i.e. returns a = AbstractOperator(ScalarField, :a)
# :($(esc(a)) = AbstractOperator(ScalarField, Expr($(esc(a)))) )

# a = AbstractOperator(ScalarField, :a)
# nameof(typeof(a))
# fieldnames(typeof(a))
# field(a) == a.field

macro field(name)
    return quote
        abstract type $name <: Field end
    end
end

macro operator(field, op)
    return :($(esc(op)) = AbstractOperator($(esc(field)), $(Expr(:quote, Symbol(string(op))))))
end

macro operators(field, ops...)
    # Check each op is a unique symbol.
    [ops...] == unique(ops) || error("Duplicate operator names in @operators: $ops")
    return Expr(:block, 
        [ :($(esc(op)) = AbstractOperator(
            $(esc(field)), $(Expr(:quote, Symbol(string(op))))
        )) for op in ops]...
    )
end

macro comm(ex)
    MacroTools.@capture(ex, [a_, b_] = c_) || error("expected a commutation relation of the form [a(p), b(q)] = f(p,q)")
    # println("[$(esc(a)),$(esc(b))] = $c")
    # println(@__MODULE__)
    # println(__module__)
    return quote
        # println(typeof($(esc(a))),typeof($(esc(b))))
        function $(esc(:comm))($(esc(:u1))::Operator{field($(esc(a)))}, $(esc(:u2))::Operator{field($(esc(b)))})
            esc_a = $(esc(a))
            esc_b = $(esc(b))
            # println("$esc_a, $esc_b")
            # println("comm called with [$u1, $u2]")
            if esc_a == one(Operator{field(esc_a)}) || esc_b == one(Operator{field(esc_b)})
                return 0
            elseif !((esc_a.name == u1.name || esc_b.name == u2.name) || (esc_a.name == u2.name || esc_b.name == u1.name))
                return 0
            elseif u1.adjoint == esc_a.adjoint && u2.adjoint == esc_b.adjoint || u1.adjoint == esc_b.adjoint && u2.adjoint == esc_a.adjoint
                cc = substitute($(esc(c)), Dict(zip(esc_a.indices, u1.indices)) ∪ Dict(zip(esc_b.indices, u2.indices)))
                # Parity fixing ± the specified commutation due to antisymmetry of the Lie bracket
                return (-1)^(Int(u1.adjoint == esc_b.adjoint) + Int(u1.name == esc_b.name)) * cc
            else
                return 0
            end
        end
    end
end

# @field TestField
# @operators TestField ee ll
# @syms p q g h
# # @comm [b(p,g), c(q,h)'] = 2 * E(p) * twopi^3 * δ(p - q) * (g == h)
# # comm(b(p,t), c(q,p)')
# @comm [ee(q), ll(p)'] = 5
# comm(ee(q), ll(p)')