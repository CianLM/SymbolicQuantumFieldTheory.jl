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