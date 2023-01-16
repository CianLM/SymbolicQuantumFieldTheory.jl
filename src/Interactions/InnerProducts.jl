function *(a::Bra,b::Ket)
    # Assuming orthogonality (as holds in QFT)
    # but not in finite systems like the harmonic oscillator
    # If they have different number of particles return 0
    if length(a.op) != length(b.op)
        return 0
    else
        return get(OperatorTerm(normalorder(a.op' * b.op)).terms, one(Operator), 0)
    end
end
v = vacuum()
p = a_p' * v
q = a_q' * v
v' * v == vacuum()' * vacuum() == Bra() * Ket() == 1
q' * p
p' * q
v' * a_p' == v' * a_p' *  v == v' * p == 0

e = ℯ
# Sym
simplify(e^(im*α) * e^(-im*α))
@syms 𝛼::Complex
α*Ket()
(conj(𝛼)*𝛼) ^ 0.5
@variables 𝐵::Complex
norm(𝐵) = conj(𝐵)*𝐵
norm(𝐵)


function *(a::BraState,b::KetState)
    # return sum(va * vb for (ka,va) in a.states for (kb,vb) in b.states if ka' == kb)
    # refactor as empty sum angers the compiler
    s = 0
    for (ka,va) in a.states
        for (kb,vb) in b.states
            # println(ka' == kb, " ", ka, " ", kb, " ", va * vb)
            s += va * vb * (ka * kb)
        end
    end
    return s
end

*(a::BraState,b::Ket) = a * KetState(Dict{Ket,SymorNum}(b => 1))
*(a::Bra,b::KetState) = BraState(Dict{Bra,SymorNum}(a => 1)) * b
@syms α β
@syms p₁ p₂ q₁ q₂
@ScalarFieldOperator a
i = (α * a(p₁)' + β * a(p₂)') * v
f = (α * a(q₁)' + β * a(q₂)') * v
ip = f' * i

sym_pi = SymbolicUtils.Sym{Number}(:π)
r = @rule α*conj(α) => 1
r(ip)
v = vacuum()
a = a_p' * a_q' * v
b = a_k' * v
a' * b


i = a_p' * v
f = a_q' * v
f' * i