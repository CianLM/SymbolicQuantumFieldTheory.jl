@testset begin "TermInterface Integration"
    @syms α β
    a_p = a(p)
    a_q = a(q)

    ap_term = α * a_p + β * a_p * a_q + p * a(q)^5


    istree(ap_term)
    exprhead(ap_term)
    operation(ap_term)
    arguments(ap_term)

    substitute(ap_term, Dict(p => -q))
end


@testset "OperatorTerm" begin
    @operators a_p * a_q
    @syms α β γ
    q = (α + β) * a_p * a_q
    p = β * a_q * a_p

    q * p
    p * q
    p + q
    q + p
    a_p + α * a_q
    a_p + a_q + a_p

    a_p + a_q
    a_p * a_q + α * a_p * a_q + 2
end