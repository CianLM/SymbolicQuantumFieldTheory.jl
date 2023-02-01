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
@field DiracField

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
    println("[$a,$b] = $c")
    # println("$(Operator{field(eval(a))})")
    @syms 𝚕 𝚛
    return quote
        # println(typeof($a),typeof($b))
        function $(esc(:comm))(𝚕::Operator{field($a)}, 𝚛::Operator{field($b)})
            println("comm called with [$𝚕, $𝚛]")
            if $a == one(Operator{field($a)}) || $b == one(Operator{field($b)})
                println("one")
                return 0
            elseif !(($a.name == 𝚕.name || $b.name == 𝚛.name) || ($a.name == 𝚛.name || $b.name == 𝚕.name))
                println($a.name, 𝚕.name, $b.name, 𝚛.name)
                println(($a.name != 𝚕.name || $b.name != 𝚛.name), ($a.name != 𝚛.name || $b.name != 𝚕.name))
                return 0
            elseif 𝚕.adjoint == $a.adjoint && 𝚛.adjoint == $b.adjoint || 𝚕.adjoint == $b.adjoint && 𝚛.adjoint == $a.adjoint
                println("substituting...")
                cc = substitute($c, Dict(zip($a.indices, 𝚕.indices)) ∪ Dict(zip($b.indices, 𝚛.indices)))
                # Parity fixing ± the specified commutation due to antisymmetry of the Lie bracket
                return (-1)^(Int(𝚕.adjoint == $b.adjoint) + Int($𝚕.name == b.name)) * cc
            else
                println("else")
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

