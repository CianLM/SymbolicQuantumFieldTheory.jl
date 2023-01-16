# ! SCALAR FIELD
@syms δ(p) E(p)
sym_pi = SymbolicUtils.Sym{Number}(:π)
twopi = 2 * sym_pi

function comm(a::Operator, b::Operator)
    # Is overwritten by specific commutators for given fields
    return 0
end

function comm(a::Operator{ScalarField}, b::Operator{ScalarField})
    if a == one(Operator{ScalarField}) || b == one(Operator{ScalarField})
        return 0
    end
    if a.name != b.name
        return 0
    end
    p = a.indices[1]
    q = b.indices[1]
    # 3D
    # a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) * 2 * E(p) * twopi^3 * Delta(p - q)^3 : 0
    # !!! 1D
    a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) * twopi * δ(p - q) : 0
    # testing
    # a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) : 0
end
@syms p q
comm(a_p,a_q')

function comm(a::Operator, b::OperatorProduct)
    return b[1] * comm(a, b[2:end]) + comm(a, b[1]) * b[2:end]
end

function comm(a::OperatorProduct, b::Operator)
    return a[1] * comm(a[2:end], b) + comm(a[1], b) * a[2:end]
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
function comm(a::Operator{ScalarField}, b::OperatorPower)
    # Requires [a,[a,b]] = 0 i.e. comm(a,b) is scalar
    # https://math.stackexchange.com/questions/2100302/commutator-of-an-a-dagger-n
    return b.power * b.operator^(b.power - 1) * comm(a, b.operator)
end
comm(a::OperatorPower, b::Operator) = -comm(b, a)
comm(k, l)
comm(l, k)

function comm(a::OperatorPower, b::OperatorPower)
    # Only for scalar field https://physics.stackexchange.com/questions/45053/what-is-the-cleverest-way-to-calculate-hatam-hata-dagger-n-when
    return a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) * sum([factorial(i) * binomial(a.power, i) * binomial(b.power, i) * b.operator^(b.power - i) * a.operator^(a.power - i) * comm(a.operator,b.operator)^i for i in 1:min(a.power, b.power)]) : 0
end
comm(a_p^2,a_k')
comm(a_p^2, a_q'^1)
comm(a_p^2, a_q')
comm(a_p^50, a_q'^3)
comm(a_p^2,a_q'^2)

a_p^2 * a_q'^2 - a_q'^2 * a_p^2

@typeof comm(a_p,a_k')


function comm(x::OperatorTerm, y::OperatorTerm)
    I = one(Operator)
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

comm(a::T where T<:OperatorSym, b::OperatorTerm) = comm(OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1)), b)
comm(a::OperatorTerm, b::T where T<:OperatorSym) = comm(a, OperatorTerm(Dict{OperatorSym,SymorNum}(b => 1)))
comm(a::OperatorTerm, b::SymorNum) = 0
comm(a::SymorNum, b::OperatorTerm) = 0
comm(a::SymorNum, b::SymorNum) = 0

function comm(a::OperatorProduct, b::OperatorPower)
        return a[1] * comm(a[2:end], b) + comm(a[1], b) * a[2:end]
end

function comm(a::OperatorPower, b::OperatorProduct)
        return b[1] * comm(a, b[2:end]) + comm(a, b[1]) * b[2:end]
end

comm(3a_p, 2a_q' * a_p + a_q')
comm(a_p,a_q * a_k')
comm(a_q * a_k', a_p)
@syms l
a_l = a(l)
comm(a_p * a_q, a_k' * a_l')
comm(a_p * a_p, a_q' * a_q')
comm(a_p^2, a_q'^2)
comm(a_p, a_k')
comm(a_p^2, a_q'^3)
# needs normal ordering
comm(a_p, 3a_q') == 3comm(a_p, a_q') == comm(3a_p, a_q')