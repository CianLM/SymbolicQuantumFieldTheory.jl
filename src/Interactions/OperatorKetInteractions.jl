vacuum() = Ket()

function *(a::Union{Operator,OperatorPower}, b::Ket)
    if a == one(Operator)
        return b
    elseif !a.adjoint && b == vacuum()
        # a∣0⟩ = 0
        return 0
    elseif !a.adjoint
        # for i in b.indices 
        b_op = b.op
        return normalorder(a * b_op) * vacuum()
    elseif a.adjoint && b == vacuum()
        # aₚ^† ∣0⟩ = ∣p⟩
        return Ket(a)
    else
        # aₚ^† ∣q⟩ = ∣p; q⟩
        return Ket(a * b.op)
    end
end
v = vacuum()
a_p * vacuum()
p = a_p' * vacuum()
a_q * p
a_p' * p
a(-q)'^2 * p
normalorder(a_q * a_p * a(k)' * a_l')

function *(a::OperatorProduct, b::Ket)
    if !a[end].adjoint && b == vacuum()
        # a∣0⟩ = 0
        return 0
    end
    if isnormalordered(a)
        return Ket(a * b.op)
    else
        # Otherwise, we need to do some normal ordering
        return normalorder(a * b.op) * vacuum()
    end
end

function *(a::OperatorTerm, b::Ket)
    d = Dict{Ket,SymorNum}()
    println(a)
    for (ka, va) in a.terms
        applied = ka * b
        # print(typeof(ka), " ", typeof(b), " ", typeof(applied), " ")
        println("$ka * $b = $applied")
        if applied isa Ket
            # println("$applied is a Ket")
            d[applied] = get(d, applied, 0) + va
        elseif applied isa KetState
            # println("$applied is a KetState")
            for (kb, vb) in applied
                d[kb] = get(d, kb, 0) + va * vb
            end
        else
            println("Unexpected Term: $applied is neither a Ket nor a KetState")
        end
    end
    return isempty(d) ? 0 : KetState(d)
end

function *(a::OperatorTerm, b::KetState)
    # Uses OperatorTerm * Ket Multiplication
    d = Dict{Ket,SymorNum}()
    for (kb, vb) in b.states
        applied = a * kb
        if applied isa Ket
            d[applied] = get(d, applied, 0) + vb
        elseif applied isa KetState
            for (kc, vc) in applied.states
                d[kc] = get(d, kc, 0) + vb * vc
            end
        end
    end
    return isempty(d) ? 0 : KetState(d)
end

*(a::T where {T<:OperatorSym}, b::KetState) = OperatorTerm(Dict{OperatorSym,SymorNum}(a=>1)) * b

# Bras
*(a::Bra, b::T where {T<:OperatorSym}) = (b' * a')'
*(a::Bra, b::OperatorTerm) = (b' * a')'
*(a::BraState, b::T where {T<:OperatorSym}) = (b' * a')'
*(a::BraState, b::OperatorTerm) = (b' * a')'


# !!! testing
@syms α
@variables 𝛼
typeof(𝛼) <: SymorNum
r = @rule conj(conj(x)) => x

q = vacuum()' * (a_p * a_q)
vacuum()' * a_p * a_q

(a_p' * a_q') * vacuum()
one(Operator)^2 * vacuum()
# |p⟩ = a†ₚ |0⟩
# aₚ|p⟩ = |0⟩

normalorder(a_p * a_q' * a_k')

v = vacuum()
p1 = a_p' * v
p2 = a_q' * p1
p2 *= α
p3 = a_k * p2
p4 = a_l' * p3


va = a_k * a_p' * a_q' * v
vc = a_k * (a_p' * a_q') * v
vb = a_k * a_p' * (a_q' * v)
# normalorder(vb)
va == vb == vc
normalorder(a_k * a_l * a_p' * a_q') * va
2(a_k' * a_l') * va

# Ket((:q, :p)) + Ket((:p, :q))

a_p^2 * v
a_p'^2 * v
a_p'^2 * a_q' * v
a_p'^2 * (a_q' * v)
a_q^2 * (a_p'^3 * v)
a_q^2 * a_p'^3 * v

v' *  a_p^2 * a_q^2 * a_k'^2
v' * (a_p^2 * a_q^2 * a_k'^2)
v' * (a_p^2 * a_q^2 * a_k'^2 * a_l'^2  * v)
v' * (a_p^2 * a_q^2 * a_k'^2 * a_l'^2) * v
v' * (a_p^2 * a_q^2 * a_k'^2 *(a_l'^2  * v))
normalorder(a_p * a_q^2 * a_k'^2 * a_l')

@syms b::Complex
@typeof b
b * conj(b)

a_k^2 * (a_q'^2 * a_p'^2 * v)
(a_k^2 * a_q'^2 * a_p'^2) * v

normalorder(a_k * normalorder(a_k * a_q'^2 * a_p'^2)) * v 
normalorder(a_k^2 * a_q'^2 * a_p'^2) * v

@syms p q
a = a_p' * a_q' * a_k' * a_l' * v
b = a_q' * a_p' * a_k' * a_l' * v
v
i =  a_p' * v
o =  a_q' * v
sc = p * o' * i
_pi = SymbolicUtils.Sym{Number}(:π)
substitute(sc, Dict(
    δ(q - p) => 1,
     p => -Symbolics.solve_for(
        arguments(δ(q - p))[1] ~ 0, p
    )
))
