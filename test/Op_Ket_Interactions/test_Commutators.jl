@testset "Commutators" begin
    @operators ScalarField a
    @syms p q k l
    @syms δ(p) E(p)


    @testset "Comm Rel Generation" begin
        @field DiracField
        @operators DiracField b c
        @comm [b(p),c(q)'] = E(p) * δ(p - q)
        @test comm(b(k),c(l)') - E(k) * δ(k - l) == 0
        # Delta Function Evenness
        @test_broken comm(b(k),c(l)') == -comm(b(k)',c(l)) == -comm(c(l)',b(k)) == comm(c(l),b(k)')
    end
    @testset "Scalar Field" begin

        @test comm(a(p), a(q)) == comm(a(p)', a(q)') == 0
        # Delta Function Evenness
        @test_broken comm(a(p), a(q)') == -comm(a(p)', a(k)) == 1

        @testset "Adjoints" begin
            x = a(p) * a(q)' + a(p)
            y = 1 + a(q)
            @test x' == a(q) * a(p)' + a(p)'
            @test y' == a(q)' + 1
        end
    end

    @testset "Stress Test" begin
        @syms c
        x = c * a(p)'^2 * 1/c * a(q)'^2 + a(p)^2 * a(q)'^2 + a(p) * a(q)
        @test isnormalordered(x) == false
        # for o in keys(x.terms)
        #     println(o)
        # end
        @test isnormalordered(normalorder(x)) == true
    end

    @testset "Stress Test 2" begin
        @syms c
        ex = 3 * a(p) * a(q)' + a(p) * a(p)'
        normalorder(ex)

        normalorder(a(p) * a(q) + c * a(q) * a(p) * a(p) + 3a(p)^2 * a(q)'^2)

        @test normalorder(a(p)^2 * a(q)'^2) == normalorder(c * a(p)^2 * 1 / c * a(q)'^2)
        @test comm(a(p)^2, a(q)'^2) == normalorder(a(p)^2 * a(q)'^2 - a(q)'^2 * a(p)^2)
    end

    @testset "Methods" begin
        a_p, a_q, a_k, a_l = a(p), a(q), a(k), a(l)
        sym_pi = SymbolicUtils.Sym{Number}(:π)
        twopi = 2 * sym_pi
        @test comm(a_p, a_q') - twopi * δ(p - q) == 0
        @test comm(a_p,a_q') - (-comm(a_p',a_q)) == 0
        @testset "comm(a::Operator{ScalarField}, b::OperatorPower)" begin
            @test comm(a_p^2,a_k') == 2 * twopi * δ(p - k) * a_p
        end

        @testset "comm(a::OperatorPower, b::OperatorPower)" begin
            @test comm(a_p^50, a_q'^3) == normalorder(a_p^50 * a_q'^3 - a_q'^3 * a_p^50)
            @test comm(a_p^2,a_q'^2) == normalorder(a_p^2 * a_q'^2 - a_q'^2 * a_p^2)
        end

        @testset "comm(a::OperatorPower, b::OperatorProduct)" begin
            @test comm(3a_p, 2a_q' * a_p + a_q') == normalorder(3a_p * (2a_q' * a_p + a_q') - (2a_q' * a_p + a_q') * 3a_p)
            @test comm(a_p, a_q * a_k') == normalorder(a_p * a_q * a_k' - a_q * a_k' * a_p)
            # Delta function evenness breaks this test but it works otherwise
            @test_broken comm(a_q * a_k', a_p) == normalorder(a_q * a_k' * a_p - a_p * a_q * a_k')
            @test comm(a_p * a_q, a_k' * a_l') == normalorder(a_p * a_q * a_k' * a_l' - a_k' * a_l' * a_p * a_q)
            @test comm(a_p * a_p, a_q' * a_q') == normalorder(a_p * a_p * a_q' * a_q' - a_q' * a_q' * a_p * a_p)
            @test comm(a_p^2, a_q'^2) == normalorder(a_p^2 * a_q'^2 - a_q'^2 * a_p^2)
            @test comm(a_p^2, a_q'^3) == normalorder(a_p^2 * a_q'^3 - a_q'^3 * a_p^2)
        end
        

    end

end
# Use grep to find all occurances of println in the code
# grep -r "println" src 