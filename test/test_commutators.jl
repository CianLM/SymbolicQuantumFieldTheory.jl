@testset "Commutators" begin
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

end