struct KetState <: State
    # The state is represented as a dictionary of ket names mapping to coefficients.
    # Coefficients are either Symbolic or Numbers.
    states::Dict{Ket,SymorNum}

    function KetState(states::Dict{Ket,SymorNum})
        # Filter for zero coefficients
        states = filter(x -> x[2] isa SymbolicUtils.Symbolic ? true : x[2] != 0, states)
        # could just be if we arent using @variables
        # states = filter(x -> x[2] isa Number ? x[2] != 0 : true, states)
        isempty(states) && return 0
        return new(states)
    end
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

function Base.show(io::IO, ::MIME"text/latex", s::KetState)
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



begin "TermInterface"
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
end

function Base.:(==)(x::KetState, y::KetState)
    return isequal(x.states, y.states)
end

function Base.:(==)(x::KetState, y::Ket)
    return isequal(x.states, Dict{Ket,SymorNum}(y => 1))
end

function Base.:(==)(x::Ket, y::KetState)
    return isequal(y.states, Dict{Ket,SymorNum}(x => 1))
end

Base.iterate(x::KetState) = iterate(x.states)
Base.iterate(x::KetState, i::Int) = iterate(x.states, i::Int)

function +(a::KetState, b::KetState)
    d = Dict{Ket,SymorNum}(
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

+(a::KetState, b::Ket) = a + KetState(Dict{Ket,SymorNum}(b => 1))
+(a::Ket, b::KetState) = KetState(Dict{Ket,SymorNum}(a => 1)) + b
+(a::KetState, b::SymorNum) = b == 0 ? a : a + KetState(Dict{Ket,SymorNum}(Ket() => b))
+(a::SymorNum, b::KetState) = b + a

-(a::KetState) = KetState(Dict{Ket,SymorNum}(k => -v for (k, v) in a.states))
-(a::KetState, b::KetState) = a + (-b)

*(a::KetState, b::Number) = KetState(Dict{Ket,SymorNum}(k => v * b for (k, v) in a.states))
*(a::Number, b::KetState) = b * a
/(a::KetState, b::Number) = a * (1 / b)

*(a::KetState, b::SymbolicUtils.Symbolic) = KetState(Dict{Ket,SymorNum}(k => v * b for (k, v) in a.states))
*(a::SymbolicUtils.Symbolic, b::KetState) = b * a
/(a::KetState, b::SymbolicUtils.Symbolic) = a * (1 / b)


### Kets
+(a::Ket, b::Ket) = a == b ? KetState(Dict{Ket,SymorNum}(a => 2)) : KetState(Dict{Ket,SymorNum}(a => 1, b => 1))

-(a::Ket, b::Ket) = a == b ? 0 : KetState(Dict{Ket,SymorNum}(a => 1, b => -1))
*(a::Ket, b::SymorNum) = KetState(Dict{Ket,SymorNum}(a => b))
*(b::SymorNum, a::Ket) = KetState(Dict{Ket,SymorNum}(a => b))
/(a::Ket, b::SymorNum) = KetState(Dict{Ket,SymorNum}(a => 1 / b))

*(a::Ket, b::SymbolicUtils.Symbolic) = KetState(Dict{Ket,SymorNum}(a => b))
*(a::SymbolicUtils.Symbolic, b::Ket) = KetState(Dict{Ket,SymorNum}(b => a))
/(a::Ket, b::SymbolicUtils.Symbolic) = KetState(Dict{Ket,SymorNum}(a => 1 / b))