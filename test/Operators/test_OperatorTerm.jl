

@testset "OperatorTerm" begin
    @testset "Don't Error" begin
        @syms α β γ
        q = (α + β) * a_p * a_q
        p = β * a_q * a_p
        
        q * p
        p * q
        p + q
        q + p
        a_p + α * a_q
        a_p + a_q + a_p
        
        a_p + a_q
        @test a_p * a_q + α * a_p * a_q + 2 == (1 + α) * a_p * a_q + 2
    end

    @testset "Random Tests" begin
        @operator ScalarField a
        @syms p q
        @syms m g l
        @syms α β
        test_term =  β * a(m) + q * a(-q) * a(q)
        test_term * test_term

        (a(-q) * a(q)) * (a(q) * a(q) * a(-q))
        a(q - p) - a(p - q)
        
        @test (a(q) * a(-q)) * (a(-q) * a(-q) * a(q)) == (α * a(q) * a(-q)) * (a(-q) * 1/α * a(-q) * a(q))
        @test startswith(string(hash(a(m) + a(-m))), "46") 
    end

    @testset "TermInterface Integration" begin
        @syms α β
        a_p = a(p)
        a_q = a(q)
    
        ap_term = α * a_p + β * a_p * a_q + p * a(q)^5
    
    
        istree(ap_term)
        # exprhead(ap_term)
        operation(ap_term)
        arguments(ap_term)
    
        @test substitute(ap_term, Dict(p => -q)) == α * a(-q) + β * a(-q) * a(q) - q * a(q)^5
    end
    
end