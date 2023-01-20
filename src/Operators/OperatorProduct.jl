struct OperatorProduct <: OperatorSym
    operators::Vector{OporPower}

    function OperatorProduct(x::Vector{Union{Operator,OperatorPower}})
        if isempty(x)
            return 1
        elseif length(x) == 1
            return x[1]
        else
            new(x)
        end
    end

    # Given a spread vector of operators, return a new OperatorProduct
    function OperatorProduct(x::OporPower...)
        # collect makes this type stable! amazing
        return OperatorProduct(collect(OporPower, x))
    end

end

begin "TermInterface"
    function istree(x::OperatorProduct)
        #println("OperatorProduct: istree called on $x")
        return true
    end

    function exprhead(x::OperatorProduct)
        #println("OperatorProduct: Exprhead called on $x")
        return :call
    end

    function operation(x::OperatorProduct)
        #println("OperatorProduct: Operation called on $x")
        return OperatorProduct
    end

    function arguments(x::OperatorProduct)
        #println("OperatorProduct: Arguments called on $x")
        return x.operators
    end

    function metadata(x::OperatorProduct)
        #println("OperatorProduct: Metadata called on $x")
        return nothing
    end

    function similarterm(t::OperatorProduct, f, args, symtype; metadata=nothing)
        #println("OperatorProduct: similar term called with $f, $args, $symtype, $metadata, $exprhead")
        return f(args...)
    end
end

function Base.show(io::IO, s::OperatorProduct)
    print(io, join(s.operators, " "))
end

function Base.show(io::IO, ::MIME"text/latex", s::OperatorProduct)
    print(io, join(s.operators, " "))
end

function length(x::OperatorProduct)
    return length(x.operators)
end

function reverse(x::OperatorProduct)
    return OperatorProduct(reverse(x.operators))
end

Base.iterate(x::OperatorProduct) = iterate(x.operators)
Base.iterate(x::OperatorProduct, i::Int) = iterate(x.operators, i::Int)
Base.firstindex(x::OperatorProduct) = 1
Base.getindex(x::OperatorProduct, i::Int) = x.operators[i]
Base.getindex(x::OperatorProduct, i::AbstractVector{Int}) = OperatorProduct(x.operators[i])
Base.setindex!(x::OperatorProduct, v::OporPower, i::Int) = x.operators[i] = v
Base.lastindex(x::OperatorProduct) = length(x.operators)

function Base.:(==)(x::OperatorProduct, y::OperatorProduct)
    # if isnormalordered(x) && isnormalordered(y)
    return isequal(x.operators, y.operators)
    # else
    #     return isequal(normalorder(x), normalorder(y))
    # end
end

function *(x::Operator, y::Operator)
    if x == one(Operator)
        return y
    elseif y == one(Operator)
        return x
    else
        return x == y ? OperatorPower(x, 2) : OperatorProduct(OporPower[x, y])
    end
end
# @syms p q
# a_p = a(p)
# a_q = a(q)
# @syms k l
# a_k = a(k)
# a_l = a(l)
# a_p * a_q

function Base.:(*)(x::OperatorProduct, y::Operator)
    y == one(Operator) && return x
    endop, power = x[end] isa OperatorPower ? (x[end].operator, x[end].power) : (x[end],1)
    if endop != y
        return OperatorProduct(OporPower[x.operators..., y])
    else
        front = x[begin:end-1] isa OperatorProduct ? x[begin:end-1] : [x[begin:end-1]]
        return OperatorProduct(OporPower[front..., OperatorPower(y, power + 1)])
    end
end
# a_p * a_q * a_k
# a_p * a_q * a_q
# a_p * a_q^2 * a_q
# a_p * a_q^2 * a_k

function Base.:(*)(x::Operator, y::OperatorProduct)
    return reverse(reverse(y) * x)
end
# a_p * (a_q * a_k)
# a_p * (a_q * a_q)
# a_p * (a_q^2 * a_q)
# a_p * (a_q^2 * a_k)

function Base.:(*)(x::OperatorProduct, y::OperatorProduct)
    endop, endpower = x[end] isa OperatorPower ? (x[end].operator, x[end].power) : (x[end],1)
    startop, startpower = y[1] isa OperatorPower ? (y[1].operator,y[1].power) : (y[1],1)
    if endop != startop
        return OperatorProduct(OporPower[x.operators..., y.operators...])
    else
        front = x[begin:end-1] isa OperatorProduct ? x[begin:end-1] : [x[begin:end-1]]
        back = y[2:end] isa OperatorProduct ? y[2:end] : [y[2:end]]
        power = startpower + endpower
        return OperatorProduct(OporPower[front..., OperatorPower(endop, power), back...])
    end
end
# (a_p * a_q) * (a_k * a_p)
# (a_p * a_q^2) * (a_q * a_p)
# (a_p * a_q^2) * (a_k * a_p)
# (a_p * a_q) * (a_q^2 * a_p)
# (a_p * a_k) * (a_q^2 * a_p)
# (a_p * a_q^2) * (a_q^2 * a_k)

function Base.:(*)(a::OperatorProduct,b::OperatorPower)
    b == one(OperatorPower) && return a
    endop, endpower = a[end] isa OperatorPower ? (a[end].operator, a[end].power) : (a[end],1)
    if endop != b.operator
        return OperatorProduct(OporPower[a.operators..., b])
    else
        front = a[begin:end-1] isa OperatorProduct ? a[begin:end-1] : [a[begin:end-1]]
        return OperatorProduct(OporPower[front..., OperatorPower(endop, endpower + b.power)])
    end
end
# reverse(a_p^3 * a_k) * a_p^2
# reverse(a_q^3 * a_k) * a_p^2
# reverse(a_p * a_q * a_k) * a_p^2
# reverse(a_p * a_k) * a_p^2


function Base.:(*)(a::OperatorPower,b::OperatorProduct)
    return reverse(reverse(b) * a)
end
# reverse(a_p^2 * (a_p^3 * a_k))
# reverse(a_p^2 * (a_q^3 * a_k))
# reverse(a_p^2 * (a_p * a_q * a_k))
# reverse(a_p^2 * (a_p * a_k))

function Base.hash(a::OperatorProduct, h::UInt=UInt(0))
    h = Base.hash(length(a), h)
    for x in a.operators
        h = Base.hash(x, h)
    end
    return h
end