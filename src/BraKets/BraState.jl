struct BraState <: State
    # The state is represented as a dictionary of Bra names mapping to coefficients.
    # Coefficients are either Symbolic or Numbers.
    states::Dict{Bra,SymorNum}

    function BraState(states::Dict{Bra,SymorNum})
        # Filter for zero coefficients
        states = filter(x -> x[2] isa SymbolicUtils.Symbolic ? true : x[2] != 0, states)
        isempty(states) && return 0
        return new(states)
    end

end

function Base.show(io::IO, s::BraState)
    # Iterate over the dictionary and add the Bra and the coefficient joined by +
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
                # If the coefficient is -1, then print -Bra
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

function Base.show(io::IO, ::MIME"text/latex", s::BraState)
    # Iterate over the dictionary and add the Bra and the coefficient joined by +
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
                # If the coefficient is -1, then print -Bra
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


begin "TermInterface"
    function istree(x::BraState)
        return true
    end

    function exprhead(x::BraState)
        return :call
    end

    function operation(x::BraState)
        return +
    end

    function arguments(x::BraState)
        return keys(x.states) .* values(x.states)
    end

    function similarterm(t::BraState, f, args, symtype=Bra, metadata=nothing, exprhead=exprhead(t))
        return f(args...)
        # return SymbolicUtils.Term{symtype}(f, args, metadata, exprhead)
    end
end

function Base.:(==)(x::BraState, y::BraState)
    return isequal(x.states, y.states)
end

function Base.:(==)(x::BraState, y::Bra)
    return isequal(x.states, Dict(y => 1))
end

function Base.:(==)(x::Bra, y::BraState)
    return isequal(y.states, Dict(x => 1))
end

Base.iterate(x::BraState) = iterate(x.states)
Base.iterate(x::BraState, i::Int) = iterate(x.states, i::Int)

# Take in arbitrary number of Brastates and return a Brastate
function +(a::BraState, b::BraState)
    # type = Union{typeof(values(a.states)...),typeof(values(b.states)...)}
    d = Dict{Bra,SymorNum}(
        k => get(a.states, k, 0) + get(b.states, k, 0)
        for k in keys(a.states) ∪ keys(b.states)
        if !(get(a.states, k, 0) + get(b.states, k, 0) isa Number) || get(a.states, k, 0) + get(b.states, k, 0) != 0
    )
    if isempty(d)
        return 0
    else
        return BraState(d)
    end
end

+(a::BraState, b::Bra) = a + BraState(Dict(b => 1))
+(a::Bra, b::BraState) = BraState(Dict(a => 1)) + b

-(a::BraState) = BraState(Dict(k => -v for (k, v) in a.states))
-(a::BraState, b::BraState) = a + (-b)

*(a::BraState, b::Number) = BraState(Dict(k => v * b for (k, v) in a.states))
*(a::Number, b::BraState) = b * a
/(a::BraState, b::Number) = a * (1 / b)

*(a::BraState, b::SymbolicUtils.Symbolic) = BraState(Dict(k => v * b for (k, v) in a.states))
*(a::SymbolicUtils.Symbolic, b::BraState) = b * a
/(a::BraState, b::SymbolicUtils.Symbolic) = a * (1 / b)

### Bras
+(a::Bra, b::Bra) = a == b ? BraState(Dict{Bra,SymorNum}(a => 2)) : BraState(Dict{Bra,SymorNum}(a => 1, b => 1))
-(a::Bra, b::Bra) = a == b ? 0 : BraState(Dict{Bra,SymorNum}(a => 1, b => -1))
*(a::Bra, b::SymorNum) = BraState(Dict{Bra,SymorNum}(a => b))
*(b::SymorNum, a::Bra) = BraState(Dict{Bra,SymorNum}(a => b))
/(a::Bra, b::SymorNum) = BraState(Dict{Bra,SymorNum}(a => 1 / b))

*(a::Bra, b::SymbolicUtils.Symbolic) = BraState(Dict{Bra,SymorNum}(a => b))
*(a::SymbolicUtils.Symbolic, b::Bra) = BraState(Dict{Bra,SymorNum}(b => a))
/(a::Bra, b::SymbolicUtils.Symbolic) = BraState(Dict{Bra,SymorNum}(a => 1 / b))