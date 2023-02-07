@testset "Normal Ordering" begin
    @testset "Symbol Ordering" begin
        @test a_k' * a_l' * a_p' * a_q' * a_k * a_l * a_p * a_q ==
        symbolorder(a_q' * a_p' * a_k' * a_l' * a_k * a_l * a_q * a_p)
    end

    @testset "Commutator Equivalence" begin
        @test normalorder(a_p^2 * a_q'^2 - a_q'^2 * a_p^2) == normalorder(comm(a_p^2, a_q'^2))
        @test normalorder(a_p * a_q' * a_k') isa QFT.OperatorTerm
    end

    @testset "OperatorTerm Associativity" begin
        @test comm(a_p, 3a_q') == 3comm(a_p, a_q') == comm(3a_p, a_q')
    end

    @testset "Normal Normal Ordering" begin
        @syms b::Complex
        @test normalorder(a_p * a_q^2 * a_k'^2 * a_l') isa QFT.OperatorTerm

        
        @test a_k^2 * (a_q'^2 * a_p'^2 * v) * b == b * (a_k^2 * a_q'^2 * a_p'^2) * v
        @test normalorder(a_k * b * normalorder(a_k * a_q'^2 * a_p'^2)) * v == normalorder(a_k^2 * a_q'^2 * b * a_p'^2) * v

    end
end