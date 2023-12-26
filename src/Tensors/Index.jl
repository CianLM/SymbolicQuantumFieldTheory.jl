

struct Index
    symbol::Symbol
    covariant::Bool
    dim::Int
    function Index(symbol::Union{Symbol,AbstractString,Char}, covariant::Bool = true; dim::Int = 4)
        @assert length(string(symbol)) == 1 "Index symbol must be a single character."
        @assert dim > 0 "Dimension must be positive"
        new(Symbol(symbol), covariant, dim)
    end
end

function Base.show(io::IO, index::Index)
    print(io, index.symbol)
end

@latexrecipe function f(index::Index)
    env --> :equation
    cdot --> false
    return Expr(:call, :*, index.symbol)
end

Base.show(io::IO, ::MIME"text/latex", index::Index) = print(io, "\$\$ " * latexify(index) * " \$\$")

macro I_str(s::AbstractString)
    return Index.(Symbol.(split(s)))
end

# macro on variable
macro Index(s::Symbol)
    return :($(esc(s)) = Index($(Expr(:quote, Symbol(string(s))))))
end

# n variables
macro Indices(s::Symbol...)
    # Check each index is a unique symbol.
    [s...] == unique(s) || error("Duplicate index in @Indices: $s")
    return Expr(:block, 
        [ :($(esc(i)) = Index($(Expr(:quote, Symbol(string(i)))))) for i in s]..., nothing
    )
end

@Index μ
@Indices μ ν ρ σ τ υ ϕ ψ ω

function raise(index::Index)
    return index.covariant ? Index(index.symbol, false) : error("Index $index is already contravariant.")
end

function lower(index::Index)
    return !index.covariant ? Index(index.symbol, true) : error("Index $index is already covariant.")
end

begin "TermInterface"

    function istree(x::Index)
        # println("Is tree called on $x")
        return false
    end

    function exprhead(x::Index)
        # println("Exprhead called on $x")
        return :call
    end

    function operation(x::Index)
        # println("operation called on $x")
        return Index
    end

    function arguments(x::Index)
        # println("Arguments called on $x")
        return (x.symbol, x.covariant, x.dim)
        # return x.indices
    end

    function metadata(x::Index)
        # println("Metadata called on $x")
        return nothing
    end

    function similarterm(t::Index, f, args; exprhead=:call, metadata=nothing)
        # println("similar term called with $f, $args, $symtype, $metadata, $exprhead result: $(t.adjoint ? f(args...)' : f(args...))")
        return f(args...)
    end

end


function Base.:(==)(x::Index, y::Index)
    return isequal(x, y)
end

function Base.isequal(x::Index, y::Index)
    return hash(x) == hash(y)
end

function Base.hash(x::Index, h::UInt=UInt(0))
    h = Base.hash(string(x.symbol), h)
    h = Base.hash(string(x.covariant), h)
    h = Base.hash(string(x.dim), h)
    return h
end

