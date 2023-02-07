@testset "OperatorPowers" begin
    @operators ScalarField a
    @syms p q k l
    a_p = a(p)
    a_q = a(q)

    ap2 = a_p^2
    @test istree(ap2) == true
    # exprhead(ap2)
    operation(ap2)
    arguments(ap2)
    @test similarterm(ap2, QFT.OperatorPower, (a_q,3)) == a_q^3

    @test substitute(a(p)^5, Dict(p => q)) == a(q)^5
end