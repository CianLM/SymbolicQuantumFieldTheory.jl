@testset "AbstractOperator" begin
    @operators ScalarField a
    @operators DiracField b c
    @syms p q 
    a_p = a(p)
    a(-2p + q)
    operation(a_p)
    arguments(a_p)

    @test nameof(typeof(a)) == :AbstractOperator

    @test substitute(a(p + q)', Dict(p => q)) == a(2q)'
    @test operation(a(p + q)')(arguments(a(p - q)')...) == a(p - q)'
    @test similarterm(a(p + q)', a, (q,true)) == a(q)'

    @test istree(a(p)) == true
    # exprhead(a(p))
    @test operation(a(p)) == a

    test = a(p)'
    @test substitute(test, Dict(p => q)) == a(q)'
 
end