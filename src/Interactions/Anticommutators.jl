@syms δ(p) E(p)
sym_pi = SymbolicUtils.Sym{Number}(:π)
twopi = 2 * sym_pi

function anticomm(a::Operator, b::Operator)
    # Is overwritten by specific anticommutators for given fields
    return a*b + b*a
end

function anticomm(a::Operator{DiracField}, b::Operator{DiracField})
    if a == one(Operator{DiracField}) || b == one(Operator{DiracField})
        return 0
    end
    if a.name != b.name
        return 0
    end
    p = a.indices[1]
    q = b.indices[1]
    r = a.indices[2]
    s = b.indices[2]
    # 3D
    # a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) * 2 * E(p) * twopi^3 * Delta(p - q)^3 : 0
    # !!! 1D
    a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) * twopi * δ(p - q) * (r == s) : 0
    # testing
    # a.adjoint ⊻ b.adjoint ? (-1)^(a.adjoint) : 0
end

function anticomm(a::Operator, b::OperatorProduct)
    return (a * b[1] - b[1] * a) * b[2:end] + b[1] * anticomm(a, b[2:end])
end

function anticomm(a::OperatorProduct, b::Operator)
    return a[1] * (a[2:end] * b - b * a[2:end]) + anticomm(a[1], b) * a[2:end]
end

function anticomm(a::OperatorProduct, b::OperatorProduct)
    return a[1] * (a[2:end] * b - b * a[2:end]) + anticomm(a[1], b) * a[2:end]
end

# Op Pow / Pow Op
function anticomm(a::OperatorPower, b::Operator)
    # TODO: Add check if [a,[a,b]] = 0 and then use scalar field anticomm reductions
    return sum( a.operator^k * anticomm(a.operator, b) * a.operator^(a.power - k - 1) for k in 0:a.power-1)
end
# anticomm(a::Operator, b::OperatorPower) = -anticomm(b, a)

# function anticomm(a::Operator{ScalarField}, b::OperatorPower)
#     # Requires [a,[a,b]] = 0 i.e. anticomm(a,b) is scalar
#     # https://math.stackexchange.com/questions/2100302/anticommutator-of-an-a-dagger-n
#     return b.power * b.operator^(b.power - 1) * anticomm(a, b.operator)
# end
# anticomm(a::OperatorPower, b::Operator) = -anticomm(b, a)

# Pow Pow
function anticomm(a::OperatorPower, b::OperatorPower)
    # Makes use of anticomm(op, Pow)    ↓   here    ↓
    return sum( a.operator^k * anticomm(a.operator, b) * a.operator^(a.power - k - 1) for k in 0:a.power-1)
end

function anticomm(x::OperatorTerm, y::OperatorTerm)
    I = one(Operator)
    d = Dict{OperatorSym,SymorNum}()
    for (kx, vx) in x.terms
        for (ky, vy) in y.terms
            c = anticomm(kx, ky)
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

anticomm(a::T where T<:OperatorSym, b::OperatorTerm) = anticomm(OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1)), b)
anticomm(a::OperatorTerm, b::T where T<:OperatorSym) = anticomm(a, OperatorTerm(Dict{OperatorSym,SymorNum}(b => 1)))
anticomm(a::OperatorTerm, b::SymorNum) = 0
anticomm(a::SymorNum, b::OperatorTerm) = 0
anticomm(a::SymorNum, b::SymorNum) = 0

function anticomm(a::OperatorProduct, b::OperatorPower)
        return a[1] * anticomm(a[2:end], b) + anticomm(a[1], b) * a[2:end]
end

function anticomm(a::OperatorPower, b::OperatorProduct)
        return b[1] * anticomm(a, b[2:end]) + anticomm(a, b[1]) * b[2:end]
end
