abstract type State end

struct KetState <: State
    # The state is represented as a dictionary of ket names mapping to coefficients.
    # Coefficients are either Symbolic or Numbers.
    states::Dict{Ket,T} where {T<:Union{SymbolicUtils.Symbolic,Number}}

    function KetState(states::Dict{Ket,T}) where {T<:Union{SymbolicUtils.Symbolic,Number}}
        # Filter for zero coefficients
        states = filter(x -> x[2] isa Union{Num,Symbolic} ? true : x[2] != 0, states)
        # could just be if we arent using @variables
        # states = filter(x -> x[2] isa Number ? x[2] != 0 : true, states)
        isempty(states) && return 0
        return new(states)
    end

    function istree(x::KetState)
        return true
    end

    function exprhead(x::KetState)
        return :call
    end

    function operation(x::KetState)
        return +
    end

    function arguments(x::KetState)
        return keys(x.states) .* values(x.states)
    end

    function similarterm(t::KetState, f, args, symtype=Ket, metadata=nothing, exprhead=exprhead(t))
        return f(args...)
        # return SymbolicUtils.Term{symtype}(f, args, metadata, exprhead)
    end

    # function Base.isequal(x::KetState, y::KetState)
    #     return isequal(x.states, y.states)
    # end

    function Base.:(==)(x::KetState, y::KetState)
        return isequal(x.states, y.states)
    end

    function Base.:(==)(x::KetState, y::Ket)
        return isequal(x.states, Dict(y => 1))
    end

    function Base.:(==)(x::Ket, y::KetState)
        return isequal(y.states, Dict(x => 1))
    end

    function Base.show(io::IO, s::KetState)
        # Iterate over the dictionary and add the ket and the coefficient joined by +
        join(io,
            [
                # If v is symbolic
                if v isa SymbolicUtils.Add || v isa SymbolicUtils.Div
                    "(" * string(v) * ")" * string(k)
                elseif v isa SymbolicUtils.Symbolic || v isa Num
                    string(v) * string(k)
                    # If the coefficient is 1, then don't print it
                elseif v == 1
                    string(k)
                    # If the coefficient is -1, then print -ket
                elseif v == -1
                    "-" * string(k)
                    # If the coefficient is purely imaginary, then print bim
                elseif v == im
                    "im" * string(k)
                    # If the coefficient is purely imaginary, then print -bim
                elseif v == -im
                    "-im" * string(k)
                elseif real(v) == 0
                    string(imag(v)) * "im" * string(k)
                    # If the coefficient is complex, then print it as (a+bim)
                elseif typeof(v) <: Complex
                    "(" * string(v) * ")" * string(k)
                else
                    string(v) * string(k)
                end
                for (k, v) in s.states
            ], " + ")
    end
end

Base.iterate(x::KetState) = iterate(x.states)
Base.iterate(x::KetState, i::Int) = iterate(x.states, i::Int)

# Take in arbitrary number of ketstates and return a ketstate
function +(a::KetState, b::KetState)
    # type = Union{typeof(values(a.states)...),typeof(values(b.states)...)}
    d = Dict{Ket,Union{SymbolicUtils.Symbolic,Number}}(
        k => get(a.states, k, 0) + get(b.states, k, 0)
        for k in keys(a.states) ∪ keys(b.states)
        if !(get(a.states, k, 0) + get(b.states, k, 0) isa Number) || get(a.states, k, 0) + get(b.states, k, 0) != 0
    )
    if isempty(d)
        return 0
    else
        return KetState(d)
    end
end

+(a::KetState, b::Ket) = a + KetState(Dict(b => 1))
+(a::Ket, b::KetState) = KetState(Dict(a => 1)) + b

-(a::KetState) = KetState(Dict(k => -v for (k, v) in a.states))
-(a::KetState, b::KetState) = a + (-b)

*(a::KetState, b::Number) = KetState(Dict(k => v * b for (k, v) in a.states))
*(a::Number, b::KetState) = b * a
/(a::KetState, b::Number) = a * (1 / b)

*(a::KetState, b::SymbolicUtils.Symbolic) = KetState(Dict(k => v * b for (k, v) in a.states))
*(a::SymbolicUtils.Symbolic, b::KetState) = b * a
/(a::KetState, b::SymbolicUtils.Symbolic) = a * (1 / b)

adjoint(a::KetState) = BraState(Dict(k' => v' for (k, v) in a.states))
# α β γ δ ε ζ η θ ι κ λ μ ν ξ ο :π ρ σ τ υ φ χ ψ ω
# Italic Greek
# 𝛼 𝛽 𝛾 𝛿 𝜀 𝜁 𝜂 𝜃 𝜄 𝜅 𝜆 𝜇 𝜈 𝜉 𝜊 𝜋 𝜌 𝜍 𝜎 𝜏 𝜐 𝜑 𝜒 𝜓 𝜔

# I want to be able to do this:
# 5α ψ where α is a symbolic number and ψ is a ket
# 5α ψ + 3β ϕ where α and β are symbolic numbers and ψ and ϕ are kets
# This requires a custom tree type that can be added to and multiplied by symbolic numbers
# I also want to be able to do this:
# ψ' * ψ = 1
# bra(ψ) * ψ = 1
# bra(ψ) * ϕ = α ∈ 𝐂