@testset "Commutators" begin

    @testset "Comm Rel Generation" begin
        @field DiracField
        @operators DiracField b c
        @syms p q k l
        @comm [b(p),c(q)'] = E(p) * δ(p - q)
        @test comm(b(k),c(l)') == -comm(b(k)',c(l)) == -comm(c(l)',b(k)) == comm(c(l),b(k)')
    end
    @testset "Scalar Field" begin
        @operators a_p a_q a_k a_l

        @test comm(a_p, a_q) == comm(a_p', a_q') == 0
        @test comm(a_p, a_q') == -comm(a_p', a_k) == 1

        @testset "Adjoints" begin
            x = a_p * a_q' + a_p
            y = 1 + a_q
            @test x' == a_q * a_p' + a_p'
            @test_broken y' == a_q' + 1
        end
    end

    @testset "Stress Test" begin
        @syms c
        x = c * a_p'^2 * 1/c * a_q'^2 + a_p^2 * a_q'^2 + a_p * a_q
        isnormalordered(x)
        for o in keys(x.terms)
            println(o)
        end
        normalorder(x)
    end

    @testset "Stress Test 2" begin
        @syms a b c
        @kets ψ ϕ
        @operator a_p a_q a_k

        q = 3a * a_p * a_q' + a_p * a_p'
        normalorder(q)


        normalorder(a_p * a_q + c * a_q * a_p * a_p + 3a_p^2 * a_q'^2)

        comm(a_p * a_q, a_k' * a_p')
        normalorder(a_p^2 * a_q'^2)
        comm(a_p^2, a_q'^2)
        normalorder(c * a_p^2 * 1 / c * a_q'^2)
    end

    @testset "Methods" begin
        @syms p q k l
        a_p, a_q, a_k, a_l = a(p), a(q), a(k), a(l)
        sym_pi = SymbolicUtils.Sym{Number}(:π)
        twopi = 2 * sym_pi
        @test comm(a_p, a_q') == twopi * δ(p - q)
        @testset "comm(a::Operator{ScalarField}, b::OperatorPower)" begin
            k = a_p
            l = a_q'^3
            @test comm(k, l) == -comm(l, k) == 3*twopi * δ(p - q) * a_q'^2 
        end

        @testset "comm(a::OperatorPower, b::OperatorPower)" begin
            @test comm(a_p^2,a_k')
            @test comm(a_p^2, a_q'^1)
            @test comm(a_p^2, a_q')
            @test comm(a_p^50, a_q'^3)
            @test comm(a_p^2,a_q'^2)
        end

        @testset "comm(a::OperatorPower, b::OperatorProduct)" begin
            @testset comm(3a_p, 2a_q' * a_p + a_q')
            @testset comm(a_p, a_q * a_k')
            @testset comm(a_q * a_k', a_p)
            @testset comm(a_p * a_q, a_k' * a_l')
            @testset comm(a_p * a_p, a_q' * a_q')
            @testset comm(a_p^2, a_q'^2)
            @testset comm(a_p^2, a_q'^3)
        end
        

    end

end

