# ! SCALAR FIELD
@syms Delta(x) 
# change to δ(x) on reload
function comm(a::Operator, b::Operator)
    if a == one(Operator) || b == one(Operator)
        return 0
    end
    p = SymbolicUtils.Sym{Number}(a.indices[1])
    q = SymbolicUtils.Sym{Number}(b.indices[1])
    E_p = SymbolicUtils.Sym{Number}(Symbol("E_" * string(p)) )
    twopi = 2 * SymbolicUtils.Sym{Number}(:π)
    # a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) * 2 * E(p) * twopi^3 * Delta(p - q)^3 : 0
    # !!! 1D
    a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) * twopi * Delta(p - q) : 0
    # a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) : 0
end
@syms p q
SymbolicUtils.Sym{Number}(:p)
a_p
a_q.indices
comm(a_p,a_q')

function comm(a::Operator, b::OperatorProduct)
    if length(b) == 1
        return comm(a, b[1])
    else
        return b[1] * comm(a, b[2:end]) + comm(a, b[1]) * b[2:end]
    end
end

function comm(a::OperatorProduct, b::Operator)
    if length(a) == 1
        return comm(a[1], b)
    else
        return a[1] * comm(a[2:end], b) + comm(a[1], b) * a[2:end]
    end
end

function comm(a::OperatorProduct, b::OperatorProduct)
    if length(a) == 1
        return comm(a[1], b)
    elseif length(b) == 1
        return comm(a, b[1])
    else
        return a[1] * comm(a[2:end], b) + comm(a[1], b) * a[2:end]
    end
end
k = a_p
l = a_q'^3
function comm(a::Operator, b::OperatorPower)
    # Requires [a,[a,b]] = 0 i.e. comm(a,b) is scalar
    # https://math.stackexchange.com/questions/2100302/commutator-of-an-a-dagger-n
    return b.power * b.operator^(b.power - 1) * comm(a, b.operator)
end
comm(k, l)
comm(l, k)
comm(a::OperatorPower, b::Operator) = -comm(b, a)

function comm(a::OperatorPower, b::OperatorPower)
    # Only for scalar field https://physics.stackexchange.com/questions/45053/what-is-the-cleverest-way-to-calculate-hatam-hata-dagger-n-when
    return a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) * sum([factorial(i) * binomial(a.power, i) * binomial(b.power, i) * b.operator^(b.power - i) * a.operator^(a.power - i) * comm(a.operator,b.operator)^i for i in 1:min(a.power, b.power)]) : 0
end
comm(a_p^2,a_k')
comm(a_p^2, a_q'^1)
comm(a_p^2, a_q')
isnormalordered(
    comm(a_p^50, a_q'^3)
)
comm(a_p^2,a_q'^2) == a_p^2 * a_q'^2 - a_q'^2 * a_p^2
comm(a_p, 3a_q') == 3comm(a_p, a_q') == comm(3a_p, a_q')

function comm(x::OperatorTerm, y::OperatorTerm)
    d = Dict{OperatorSym,SymorNum}()
    for (kx, vx) in x.terms
        for (ky, vy) in y.terms
            c = comm(kx, ky)
            c isa Number && c == 0 && continue
            if c isa OperatorTerm
                for (k, v) in c.terms
                    if k isa SymorNum
                        d[I] = get(d, I, 0) + k * v * vx * vy
                    else
                        println(k, " ", v, " ", vx, " ", vy)
                        d[k] = get(d, k, 0) + v * vx * vy
                    end
                end
            else
                if c isa SymorNum
                    d[I] = get(d, I, 0) + c * vx * vy
                else
                    println(typeof(c))
                    d[c] = get(d, c, 0) + vx * vy
                end
            end
        end
        if isempty(d)
            return 0
        else
            return OperatorTerm(d)
        end
    end
end

# comm(a::Operator, b::OperatorTerm) = comm(OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1)), b)
# comm(a::OperatorTerm, b::Operator) = comm(a, OperatorTerm(Dict{OperatorSym,SymorNum}(b => 1)))
# comm(a::OperatorTerm, b::OperatorProduct) = comm(a, OperatorTerm(b))
# comm(a::OperatorProduct, b::OperatorTerm) = comm(OperatorTerm(a), b)
# comm(a::OperatorTerm, b::OperatorPower) = comm(a, OperatorTerm(Dict{OperatorSym,SymorNum}(b => 1)))
# comm(a::OperatorPower, b::OperatorTerm) = comm(OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1)), b)
comm(a::T where T<:OperatorSym, b::OperatorTerm) = 0 #comm(OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1)), b)
comm(a::OperatorTerm, b::T where T<:OperatorSym) = 0 #comm(a, OperatorTerm(Dict{OperatorSym,SymorNum}(b => 1)))
comm(a::OperatorTerm, b::SymorNum) = 0
comm(a::SymorNum, b::OperatorTerm) = 0
comm(a::SymorNum, b::SymorNum) = 0

function comm(a::OperatorProduct, b::OperatorPower)
    if length(a) == 1
        return comm(a[1], b)
    else
        return a[1] * comm(a[2:end], b) + comm(a[1], b) * a[2:end]
    end
end

function comm(a::OperatorPower, b::OperatorProduct)
    if length(b) == 1
        return comm(a, b[1])
    else
        return b[1] * comm(a, b[2:end]) + comm(a, b[1]) * b[2:end]
    end
end

comm(3a_p, 2a_q' * a_p + a_q')
comm(a_p,a_q * a_k')
comm(a_q * a_k', a_p)
@operator a_l
comm(a_p * a_q, a_k' * a_l')
comm(a_p * a_p, a_q' * a_q')
comm(a_p^2, a_q'^2)
comm(a_p, a_k')
comm(a_p^2, a_q'^3)

normalorder(x::SymorNum) = x
normalorder(x::Operator) = x
normalorder(x::OperatorPower) = x
function normalorder(x::OperatorProduct)
    # TODO: Add in total ordering of symbols to ensure that the normal ordering is unique.
    if length(x) == 1 || isnormalordered(x)
        return x
    elseif length(x) == 2
        return x[2].adjoint ? x[2] * x[1] + comm(x[1], x[2]) : x
    elseif x[1].adjoint
        return x[1] * normalorder(x[2:end])
    else
        return normalorder(x[2:end] * x[1] + comm(x[1], x[2:end]))
    end
end

function symbolorder(x::OperatorProduct)
    if !isnormalordered(x)
        return "Normal order first."
    end
    # Find the index at which the daggers end
    i = findfirst(o -> !o.adjoint, x.operators)
    y = Union{Operator,OperatorPower}[]
    # Sort the symbols before the daggers by the operators indices
    append!(y,
        sort(x[1:i-1].operators, by = o -> o isa Operator ? o.indices[1] : o.operator.indices[1])
    )
    # Sort the symbols after the daggers by the operators indices
    append!(y,
        sort(x[i:end].operators, by = o -> o isa Operator ? o.indices[1] : o.operator.indices[1])
    )
    return OperatorProduct(y)
end
symbolorder(a_q' * a_p' * a_k' * a_l' * a_k * a_l * a_q * a_p)


function normalorder(x::OperatorTerm)
    d = Dict{OperatorSym,SymorNum}()
    for (k, v) in x.terms
        nk = normalorder(k)
        if nk isa OperatorTerm
            for (kn, vn) in nk.terms
                d[kn] = get(d, kn, 0) + v * vn
            end
        else
            d[nk] = get(d, nk, 0) + v
        end
    end
    return isempty(d) ? 0 : OperatorTerm(d)
end

isnormalordered(x::SymorNum) = true
isnormalordered(x::Operator) = true
isnormalordered(x::OperatorPower) = true
function isnormalordered(x::OperatorProduct)
    return all([o.adjoint == x[1].adjoint for o in x]) || (x[1].adjoint ? isnormalordered(x[2:end]) : false)
end
isnormalordered(x::OperatorTerm) = all(isnormalordered, keys(x.terms))