@testset "Integrals" begin
v = vacuum()
@operators ScalarField a
@syms p q k l
@syms δ(p) E(p)
a_p, a_q, a_k, a_l = a(p), a(q), a(k), a(l)
sym_pi = SymbolicUtils.Sym{Number}(:π)
twopi = 2 * sym_pi

e = ℯ
ϕ = QFT.UnevaluatedIntegral( a(p) * e^(-im * p) + a(p)' * e^(im * p), p)
ϕ

# !! To be Implemented !! - Integration on OperatorTerms
@test_skip jj = QFT.UnevaluatedIntegral(a_q' * v + a_p' * v, k)
# j = QFT.UnevaluatedIntegral(1/(twopi) * p * a_p * a_k' * a_q' * v, p)
# integrate(j)
# integrate(jj)

@test integrate(a_q' * a_q * a_p' * v, q)  == twopi * a(p)' * v
@test integrate(2a_q' * a_q * a_p' * v, q) == 2 * twopi * a(p)' * v
@test integrate(2a_q' * a_q * a_p', q) * v == 2 * twopi * a(p)' * v
@test integrate(a_q' * a_q * a_p', q) * v == twopi * a(p)' * v

y = integrate(a_p' * a_p,q)
z = integrate(y * a_q')
z * v

# convert(::Type{OperatorSym}, x::Int64) = x * one(Operator)
@syms p q E(p) m
# # ℋ 
twopi = 2*SymbolicUtils.Sym{Number}(:π)
@operators ScalarField a
ℋ = 1/(twopi) * E(q) * a(q)' * a(q)
t1 = integrate(ℋ * a(-p)', q) * v # will be slow on first run
t2 = integrate(ℋ * a(-p)' * v, q)
# @typeof t1.integrand

substitute([values(t2.states)...][1], Dict(
    E(-p) => √(m^2 + p^2)
)) * [keys(t2.states)...][1]

aa = a_q' * (a_p' * a_q + 2π*δ(p - q))
b = one(QFT.Operator) * p*δ(p - q)
c = 5 * a(p) * a(q)'
@test integrate(aa, q) * v == 2π * a(p)' * v
@test integrate(aa * v, q) == 2π * a(p)' * v
@test integrate(b, p) * v == q * v
@test integrate(b * v, p) == q * v
@test integrate(c, p) * v == 5 * twopi * v
@test integrate(c * v, p) == 5 * twopi * v
Symbolics.solve_for(q - p ~ 0, q) == p
end