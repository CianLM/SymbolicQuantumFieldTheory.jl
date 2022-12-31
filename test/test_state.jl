@testset "State" begin
    @testset "KetState Operations" begin
        @ket 𝜓 𝜙 𝜒

        @test 𝜓 == Ket(:𝜓)
        @test 𝜙 == Ket(:𝜙)
        @test 𝜒 == Ket(:𝜒)

        c = rand(ComplexF64, 3)
        ks = sum(c .* [𝜓, 𝜙, 𝜒])
        @test typeof(ks) == KetState
        @test ks.states == Dict(𝜓 => c[1], 𝜙 => c[2], 𝜒 => c[3])
        q = KetState(Dict(𝜓 => c[1], 𝜙 => c[2], 𝜒 => c[3]))
        q.states
        ks.states
        @test q == ks

        a = rand(ComplexF64)
        @test a * ks == KetState(Dict(𝜓 => a * c[1], 𝜙 => a * c[2], 𝜒 => a * c[3]))
        @test ks * a == KetState(Dict(𝜓 => a * c[1], 𝜙 => a * c[2], 𝜒 => a * c[3]))
        @test_broken ks * (1 / a) == KetState(Dict(𝜓 => c[1] / a, 𝜙 => c[2] / a, 𝜒 => c[3] / a))

        @test -ks == KetState(Dict(𝜓 => -c[1], 𝜙 => -c[2], 𝜒 => -c[3]))
        @test ks + ks == KetState(Dict(𝜓 => 2 * c[1], 𝜙 => 2 * c[2], 𝜒 => 2 * c[3]))
        @test ks - ks == 0
        @test ks + ks == 2ks

        # Todo: Symbolic Tests
        @syms x y z
        @ket ψ ϕ
        typeof(α)
        typeof(ψ)
        ψ
        ϕ
        c = α * ψ
        q = β * ϕ
        norm = α^2 + β^2
        t = α / √norm * ψ + β / √norm * ϕ
        t2 = (α * ψ + β * ϕ) / sqrt(norm)
        isequal(t, t2)
        t == t2
        t - t == 0

        (2 / (5x + 3y * z)) * t2 * (5x + 3y * z) == 2t2

        y = α * ψ + (3β + sin(α)) * ψ

        # Todo
        @kets ϕ ψ
        @syms a b c
        a = ϕ + im * ψ
        typeof(a)

        q = (-3 + 4im)a / (-3 + 4im)
        q == a

    end
end