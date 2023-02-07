@testset "Bra" begin
    @operators ScalarField a
    @syms p
    I = one(typeof(a(p)))
    @test vacuum()' == vacuum()' * I'
    x = (a(p)' * vacuum())'

    @test istree(x) == true
    # exprhead(ap2)
    @test similarterm(x, operation(x), arguments(x)) == x

    @test substitute(x, Dict(p => q)) == (a(q)' * vacuum())'
end