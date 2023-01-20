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
    OperatorTerm(a::SymbolicUtils.Symbolic) = new(Dict{OperatorSym,SymorNum}(one(Operator) => a))
    OperatorTerm(a::Number) = a == 0 ? 0 : new(Dict{OperatorSym,SymorNum}(one(Operator) => a))
end
# !! for internal use only
# !! This works but could be more efficient and have a better type signature
function _OperatorTerm(x::Union{OperatorSym,SymorNum}...)
    # x is [k1, k2, ..., kn, v1, v2, ..., vn]
    # Assert x has even length
    @assert length(x) % 2 == 0
    # Construct the Dict
    # terms = Dict{OperatorSym,SymorNum}()
    # for i in 1:length(x) ÷ 2
    #     terms[x[i]] = x[i + length(x) ÷ 2]
    # end
    # More efficient construction:
    terms = Dict{OperatorSym,SymorNum}(x[1:length(x) ÷ 2] .=> x[length(x) ÷ 2 + 1:end])
    return OperatorTerm(terms)
end

length(x::OperatorTerm) = length(x.terms)


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

function Base.show(io::IO, ::MIME"text/latex", s::OperatorTerm)
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

begin "TermInterface"
    function istree(x::OperatorTerm)
        #println("OperatorTerm: $(x) istree called")
        return true
    end

    function exprhead(x::OperatorTerm)
        #println("OperatorTerm: $(x) exprhead called")
        return :call
    end

    function operation(x::OperatorTerm)
        #println("OperatorTerm: $(x) operation called")
        return _OperatorTerm
        # return +
    end

    function arguments(x::OperatorTerm)
        #println("OperatorTerm: $(x) arguments called")
        return [keys(x.terms)..., values(x.terms)...]
        # return keys(x.terms) .* values(x.terms)
    end

    function similarterm(t::OperatorTerm, f, args, symtype=symtype(t); metadata=nothing, exprhead=exprhead(t))
        #println("OperatorTerm: $(f(args...)) similar term called with $f, $args, $symtype, $metadata, $exprhead")
        # ? Can be refactored such that the logic in _OperatorTerm is implemented here.
        return f(args...)
    end
end

begin "Equalities"
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
        return isequal(normalorder(x).terms, Dict(one(Operator) => y))
    end

    function Base.:(==)(x::SymorNum, y::OperatorTerm)
        return isequal(normalorder(y).terms, Dict(one(Operator) => x))
    end
end

Base.getindex(x::OperatorTerm, i::Int) = x.terms[i]
Base.setindex!(x::OperatorTerm, v::SymorNum, i::OperatorSym) = x.terms[i] = v

# Operator Operations
begin "Operator Operations"
    +(a::T where {T<:OperatorSym}, b::SymorNum) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, one(Operator) => b))
    +(a::SymorNum, b::T where {T<:OperatorSym}) = OperatorTerm(Dict{OperatorSym,SymorNum}(one(Operator) => a, b => 1))
    +(a::T where {T<:OperatorSym}, b::T where {T<:OperatorSym}) = a == b ? OperatorTerm(Dict{OperatorSym,SymorNum}(a => 2)) : OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, b => 1))

    -(a::T where {T<:OperatorSym}) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => -1))
    -(a::T where {T<:OperatorSym}, b::SymorNum) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, one(Operator) => -b))
    -(a::SymorNum, b::T where {T<:OperatorSym}) = OperatorTerm(Dict{OperatorSym,SymorNum}(one(Operator) => a, b => -1))
    -(a::T where {T<:OperatorSym}, b::T where {T<:OperatorSym}) = a == b ? 0 : OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, b => -1))

    *(a::T where {T<:OperatorSym}, b::SymorNum) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => b))
    *(a::SymorNum, b::T where {T<:OperatorSym}) = OperatorTerm(Dict{OperatorSym,SymorNum}(b => a))
    /(a::T where {T<:OperatorSym}, b::SymorNum) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1 / b))
    # * remains to be defined for T * T where T <: OperatorSym. Is done in each file up the chain
end

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

+(a::OperatorTerm, b::SymorNum) = (b isa Number && b == 0) ? a : a + OperatorTerm(Dict{OperatorSym,SymorNum}(one(Operator) => b))
+(a::SymorNum, b::OperatorTerm) = (a isa Number && a == 0) ? b : OperatorTerm(Dict{OperatorSym,SymorNum}(one(Operator) => a)) + b
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

function Base.hash(a::OperatorTerm, h::UInt=UInt(0))
    h = hash(length(a), h)
    for (x, y) in a.terms
        h = hash(x, h)
        h = hash(y, h)
    end
    return h
end
