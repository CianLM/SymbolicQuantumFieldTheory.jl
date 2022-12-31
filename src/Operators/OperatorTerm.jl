struct OperatorTerm
    terms::Dict{OperatorSym,SymorNum}

    function OperatorTerm(terms::Dict{OperatorSym,SymorNum})
        # Filter out terms with zero coefficients
        terms = Dict(k => v for (k, v) in terms if v isa Number ? v != 0 : true)
        # If there are no terms left, return 0
        isempty(terms) && return 0
        return new(terms)
    end
    OperatorTerm(a::OperatorTerm) = new(a.terms)
    OperatorTerm(a::T where T<:OperatorSym) = new(Dict{OperatorSym,SymorNum}(a => 1))
    OperatorTerm(a::SymorNum) = new(Dict{OperatorSym,SymorNum}(I => a))

    function length(x::OperatorTerm)
        return length(x.terms)
    end

    function istree(x::OperatorTerm)
        return true
    end

    function exprhead(x::OperatorTerm)
        return :call
    end

    function operation(x::OperatorTerm)
        return +
    end

    function arguments(x::OperatorTerm)
        return keys(x.terms) .* values(x.terms)
    end

    function similarterm(t::OperatorTerm, f, args, symtype=Ket, metadata=nothing, exprhead=exprhead(t))
        return f(args...)
        # return SymbolicUtils.Term{symtype}(f, args, metadata, exprhead)
    end
end

function Base.show(io::IO, s::OperatorTerm)
    print(io, join([
            # If v is symbolic
            if v isa SymbolicUtils.Add || v isa SymbolicUtils.Div
                "(" * string(v) * ")" * string(k)
            elseif v isa SymbolicUtils.Symbolic
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
            for (k, v) in s.terms
        ], " + "))
end

function Base.:(==)(x::OperatorTerm, y::OperatorTerm)
    return isequal(normalorder(x).terms, normalorder(y).terms)
end

function Base.:(==)(x::OperatorTerm, y::OperatorSym)
    return isequal(normalorder(x).terms, Dict(y => 1))
end

function Base.:(==)(x::OperatorSym, y::OperatorTerm)
    return isequal(normalorder(y).terms, Dict(x => 1))
end

function Base.:(==)(x::OperatorTerm, y::SymorNum)
    return isequal(normalorder(x).terms, Dict(I => y))
end

function Base.:(==)(x::SymorNum, y::OperatorTerm)
    return isequal(normalorder(y).terms, Dict(I => x))
end

Base.getindex(x::OperatorTerm, i::Int) = x.terms[i]
Base.setindex!(x::OperatorTerm, v::SymorNum, i::OperatorSym) = x.terms[i] = v


# Linear Combinations of Operators

function +(a::OperatorTerm, b::OperatorTerm)
    # type = Union{typeof(values(a.states)...), typeof(values(b.states)...)}
    d = Dict{OperatorSym,SymorNum}()
    for k in keys(a.terms) ∪ keys(b.terms)
        v = get(a.terms, k, 0) + get(b.terms, k, 0)
        if !(v isa Number) || v != 0
            d[k] = v
        end
    end
    if isempty(d)
        return 0
    else
        return OperatorTerm(d)
    end
end

+(a::OperatorTerm, b::SymorNum) = b == 0 ? a : a + OperatorTerm(Dict{OperatorSym,SymorNum}(I => b))
+(a::SymorNum, b::OperatorTerm) = a == 0 ? b : OperatorTerm(Dict{OperatorSym,SymorNum}(I => a)) + b
+(a::OperatorTerm, b::T where {T<:OperatorSym}) = a + OperatorTerm(Dict{OperatorSym,SymorNum}(b => 1))
+(a::T where {T<:OperatorSym}, b::OperatorTerm) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1)) + b

-(a::OperatorTerm) = OperatorTerm(Dict{OperatorSym,SymorNum}(k => -v for (k, v) in a.terms))
-(a::OperatorTerm, b::SymorNum) = a + (-b)
-(a::SymorNum, b::OperatorTerm) = a + (-b)
-(a::OperatorTerm, b::T where {T<:OperatorSym}) = a + (-b)
-(a::T where {T<:OperatorSym}, b::OperatorTerm) = a + (-b)
-(a::OperatorTerm, b::OperatorTerm) = a + (-b)

*(a::OperatorTerm, b::SymorNum) = OperatorTerm(Dict{OperatorSym,SymorNum}(k => v * b for (k, v) in a.terms))
*(a::SymorNum, b::OperatorTerm) = b * a
/(a::OperatorTerm, b::SymorNum) = a * (1 / b)

*(a::OperatorTerm, b::T where {T<:OperatorSym}) = OperatorTerm(Dict{OperatorSym,SymorNum}((k * b) => v for (k, v) in a.terms))
*(a::T where {T<:OperatorSym}, b::OperatorTerm) = OperatorTerm(Dict{OperatorSym,SymorNum}((a * k) => v for (k, v) in b.terms))

function Base.hash(a::OperatorTerm, h::UInt=UInt(0))
    h = Base.hash(length(a), h)
    for (x, y) in a.terms
        h = Base.hash(x, h)
        h = Base.hash(y, h)
    end
    return h
end

# Products of OperatorTerms
function *(a::OperatorTerm, b::OperatorTerm)
    d = Dict{OperatorSym,SymorNum}()
    for (k1, v1) in a.terms
        for (k2, v2) in b.terms
            d[k1*k2] = get(d, k1 * k2, 0) + v1 * v2
        end
    end
    if isempty(d)
        return 0
    else
        return OperatorTerm(d)
    end
end

function adjoint(x::OperatorTerm)
    return OperatorTerm(Dict{OperatorSym,SymorNum}(k' => v' for (k, v) in x.terms))
end
