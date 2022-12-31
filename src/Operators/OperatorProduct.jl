
struct OperatorProduct <: OperatorSym
    operators::Vector{Union{Operator,OperatorPower}}

    function OperatorProduct(x::Vector{Union{Operator, OperatorPower}})
        if isempty(x)
            return 1
        elseif length(x) == 1
            return x[1]
        else
            new(x)
        end
    end
end

function Base.show(io::IO, s::OperatorProduct)
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
Base.getindex(x::OperatorProduct, i::AbstractVector{Int}) = length(i) == 1 ? x.operators[i][1] : OperatorProduct(x.operators[i])
Base.setindex!(x::OperatorProduct, v::Union{Operator,OperatorPower}, i::Int) = x.operators[i] = v
Base.lastindex(x::OperatorProduct) = length(x.operators)

function Base.:(==)(x::OperatorProduct, y::OperatorProduct)
    # if isnormalordered(x) && isnormalordered(y)
    return isequal(x.operators, y.operators)
    # else
    #     return isequal(normalorder(x), normalorder(y))
    # end
end

function *(x::Operator, y::Operator)
    if x == I
        return y
    elseif y == I
        return x
    else
        return x == y ? OperatorPower(x, 2) : OperatorProduct([x, y])
    end
end

function Base.:(*)(x::OperatorProduct, y::Operator)
    endop = x[end] isa OperatorPower ? x[end].operator : x[end]
    if endop != y
        return OperatorProduct([x.operators..., y])
    elseif x[end] isa Operator
        return OperatorProduct([x.operators[begin:end-1]..., OperatorPower(y, 2)])
    else # x.operators[end] isa OperatorPower
        return OperatorProduct([x.operators[begin:end-1]..., OperatorPower(y, x[end].power + 1)])
    end
end

function Base.:(*)(x::Operator, y::OperatorProduct)
    return reverse(reverse(y) * x)
end

function Base.:(*)(x::OperatorProduct, y::OperatorProduct)
    return OperatorProduct([x.operators..., y.operators...])
end

# +(a::OperatorProduct, b::SymorNum) = a + OperatorTerm(Dict{OperatorSym,SymorNum}(I => b))
# +(a::OperatorProduct, b::OperatorProduct) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, b => 1))

# *(b::SymorNum, a::OperatorProduct) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => b))
# /(a::OperatorProduct, b::SymorNum) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1 / b))

# +(a::Operator, b::OperatorProduct) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, b => 1))
# +(a::OperatorProduct, b::Operator) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, b => 1))
function Base.:(*)(a::OperatorPower,b::OperatorProduct)
    if b[1] isa OperatorPower && a.operator == b[1].operator
        return OperatorProduct([OperatorPower(a.operator, a.power + b[1].power), b[2:end]...])
    elseif a.operator == b[1]
        return OperatorProduct([OperatorPower(a.operator, a.power + 1), b[2:end]...])
    else
        return OperatorProduct([a, b...])
    end
end

function Base.:(*)(a::OperatorProduct,b::OperatorPower)
    return reverse(b * reverse(a))
end





function adjoint(x::OperatorProduct)
    return OperatorProduct(map(o -> o', reverse(x.operators)))
end

@operator a_p a_q a_k
@syms α β
a_p * a_q * a_k + a_p * a_k + α


function Base.hash(a::OperatorProduct, h::UInt=UInt(0))
    h = Base.hash(length(a), h)
    for x in a.operators
        h = Base.hash(x, h)
    end
    return h
end

α * a_p + 3a_q + β^2 * a_q
α * a_p * a_p'

t = a_p * a_q
q = a_p * a_q
y = a_q * a_p
Base.hash(t, UInt(0))
Base.hash(y, UInt(0))
t = 3a_p * a_q + α * a_p * a_q


a_p * a_q + a_q * a_p * a_p + 3a_p^2
