# I also want to be able to do this:
# ψ' * ψ = 1
# bra(ψ) * ψ = 1
# bra(ψ) * ϕ = α ∈ 𝐂
adjoint(α::SymbolicUtils.Symbolic) = conj(α)

function *(a::Bra,b::Ket)
    # Assuming orthogonality (as holds in QFT)
    # but not in finite systems like the harmonic oscillator
    # If they have different number of particles return 0
    if length(a.name) != length(b.name)
        return 0
    else
        a_ops = isempty(a.name) ? one(Operator) : prod([Operator(:a, (i,), false) for i in a.name])
        b_ops = isempty(b.name) ? one(Operator) : prod([Operator(:a, (i,), true) for i in b.name])
        return OperatorTerm(normalorder(a_ops * b_ops)).terms[I]
    end
end
typeof(one(Operator) * I)
v = vacuum()
p = a_p' * v
q = a_q' * v
v' * v == vacuum()' * vacuum() == Bra() * Ket() == 1
q' * p == p' * q
v' * a_p' == v' * a_p' *  v == v' * p

e = ℯ
# Sym
simplify(e^(im*α) * e^(-im*α))
@syms 𝛼::Complex
α*ψ
typeof(𝛼^2 - norm(𝛼))
(conj(𝛼)*𝛼) ^ 0.5

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

*(a::BraState,b::Ket) = a * KetState(Dict(b => 1))
*(a::Bra,b::KetState) = BraState(Dict(a => 1)) * b
@syms α β
@kets ψ φ
p = α * ψ + β * φ
ip = p' * p

r = @rule α*conj(α) + β*conj(β) => 1
r(ip)
v = vacuum()
a = a_p' * a_q' * v
b = a_k' * v
a' * b


i = a_p' * v
f = a_q' * v
f' * i

@operator a_x₁ a_x₂