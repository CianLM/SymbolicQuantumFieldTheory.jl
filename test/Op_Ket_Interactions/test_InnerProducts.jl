@testset "Inner Products" begin
    
    # Delta Functions don't understand that they are even functions
    # ! to be fixed
    @test_broken simplify(v' * (a_p^2 * a_q^2 * a_k'^2 * a_l'^2  * v) - 
     simplify(v' * (a_p^2 * a_q^2 * a_k'^2 * a_l'^2) * v)) == 0
    # v' * (a_p^2 * a_q^2 * a_k'^2 *(a_l'^2  * v))


    @testset "Substitution" begin
        @syms p q
        a = a_p' * a_q' * a_k' * a_l' * v
        b = a_q' * a_p' * a_k' * a_l' * v
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
    end

    @testset "Basic Inner Products and Vanishing Products" begin
        v = vacuum()
        pv = a_p' * v
        qv = a_q' * v
        v' * v == vacuum()' * vacuum() == 1
        qv' * pv
        pv' * qv
        @test v' * a_p' == v' * a_p' *  v == v' * pv == 0

        v = vacuum()
        a = a_p' * a_q' * v
        b = a_k' * v
        @test a' * b == 0

        i = a_p' * v
        f = a_q' * v
        @test f' * i - twopi * δ(q - p) == 0
    end

    @testset "General Inner Products" begin
        @operators ScalarField a
        @syms α β
        @syms p₁ p₂ q₁ q₂
        @operator ScalarField a
        i = (α * a(p₁)' + β * a(p₂)') * v
        f = (α * a(q₁)' + β * a(q₂)') * v
        ip = f' * i
    end
end

