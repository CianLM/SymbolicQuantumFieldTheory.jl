@testset "OperatorProducts" begin
    a_p = a(p)
    a_q = a(q)

    ap_prod = a_p * a_q


    @test istree(ap_prod) == true
    # exprhead(ap_prod)
    operation(ap_prod)
    arguments(ap_prod)
    @test similarterm(ap_prod, QFT.OperatorProduct, (a_q,a_p)) == a_q * a_p

    @test substitute(a(p) * a(q), Dict(p => -q)) == a(-q) * a(q)
end
