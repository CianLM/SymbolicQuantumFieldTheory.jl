@testset "OperatorKetInteractions" begin
    v = vacuum()
    @syms α


    @testset "Vacuum interactions" begin
        @test a_p * vacuum() == 0
        @test a_p' * vacuum() == Ket(a_p')
        @test a_p' * (a_p' * vacuum()) == Ket(a_p'^2)
    end

    @testset "Associativity" begin
        @test vacuum()' * (a_p * a_q) == vacuum()' * a_p * a_q
        @test (a_p' * a_q') * vacuum()
        @test one(Operator)^2 * vacuum()

        va = a_k * a_p' * a_q' * v
        vc = a_k * (a_p' * a_q') * v
        vb = a_k * a_p' * (a_q' * v)
        @test va == vb == vc

        a = a_p'^2 * a_q' * v
        b = a_p'^2 * (a_q' * v)
        @test a.op == b.op
        @test a == b

        @test a_q^2 * (a_p'^3 * v) == a_q^2 * a_p'^3 * v
        
        a = (v' *  a_p^2 * a_q^2 * a_k'^2)'
        b = (v' * (a_p^2 * a_q^2 * a_k'^2))'
        @test a == b
        
        

    end

    @testset "Basic Functionality" begin
        v = vacuum()
        p1 = a_p' * v
        p2 = a_q' * p1
        p2 *= α
        p3 = a_k * p2
        p4 = a_l' * p3
    end

    @testset "Stress Test" begin
        @test normalorder(a_k * a_l * a_p' * a_q') * va
        @test 2(a_k' * a_l') * va
    end
end
