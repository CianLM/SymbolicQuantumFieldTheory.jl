using Metatheory, TermInterface, Test
using Metatheory.EGraphs

@testset "Tensor" begin
    B = @Tensor B_μνρτ
    operation(B)
    arguments(B)

    similarterm(B, operation(B), arguments(B)[1:2])
    # Make a rule that substitutes μ with σ in B's indices

    relabel(:μ, :🐉, B)
    relabel(:μ, :🐉, @Tensor B_μ^ρ_ν^μ )
    raise(@Tensor B_μ^ρ_ν^μ, μ)
    @test istree(B) == true
    # @test operation(a(p)) == a
    # @test similarterm(a(p), a, (q,)) == a(q)
    @Tensor A^🐲
    @Tensor B^🐲
    tensor_field(@Tensor A^🐲)
    tensor_field(@Tensor B^🐲)
    @test @Tensor A_🔻 == Tensor(:A, [Index(:🔻)])
    @Tensor A^🐉_ν
    @Tensor A_🔻^🐲

    @Tensor A^🐲🔻

    @Tensor A_🔻🐲

    @Tensor A^🐲_🐲^🔻

    @Tensor A^🔻b🐲μ_🔻🐲

    @Tensor B_μ^ρ_ν^μ

    Bu = (@Tensor B^μνρτ)
    Bd = @Tensor B_μνρτ

    @Indices μ ν ρ τ σ α β
    ∂u(μ=@Index μ) = raise(∂(μ),μ)
    𝜓 = @Tensor(𝜓)
    ℒ = 𝜓 * (∂u() * (@Tensor(P_μν)) + (@Tensor(P_μν)) * ∂u()) * ∂u(ν) * 𝜓

    α * A * 23B_ -β * g() + ∂() * ∂(@Index ν) + α * ∂() * ∂(@Index ν)
end


# macro Tensor(names...)
#     defs = map(names) do name
#         # Check each name is of the form a_p
#         if length(string(name)) < 3 || string(name)[2] != '_'
#             error("Tensor name must be of the form a_p (multiple indices allowed i.e. a_pq)")
#         end

#         # Split the name into the Tensor name and the index
#         opname, indices = split(string(name), "_")
#         indices = Tuple(Symbol.(split(indices, "")))
#         :($(esc(name)) = Tensor($(Expr(:quote, Symbol(opname))), $(Expr(:quote, indices))))
#     end
#     return Expr(:block, defs...,
#         :(tuple($(map(x -> esc(x), names)...))))
# end


#! ### TESTING ###
# @Tensor aₚ aₖ aₐ aₑ aₕ aᵢ aⱼ aₖ aₗ aₘ aₙ aₒ aₚ aᵣ aₛ aₜ aᵤ aᵥ aₓ
# # All possible alphabetical subscripts:
# # ₐ ᵦ ᵪ ₑ ᵧ ₕ ᵢ ⱼ ₖ ₗ ₘ ₙ ₒ ₚ ᵩ ᵣ ᵨ ₛ ₔ ₜ ᵤ ᵥ ₓ
# @Tensor a_p a_q a_k
# @syms x y

# Good syntax for defining the commutation relation for a scalar field is
# @scalarfield a
# @comm [a,a'] = i



# macro comm(expr)
#     # Check that expr is of the form [a,b] = c
#     if expr.head != :(=) || expr.args[1].head == :vector || length(expr.args[1].args) != 2
#         error("Invalid commutation relation: $expr")
#     end
#     # break expr into lhs and rhs
#     lhs = expr.args[1] # [a,b]
#     rhs = expr.args[2] # c
#     # get a and b from lhs
#     a = lhs.args[1]
#     b = lhs.args[2]
#     return println("[$a,$b] = $rhs")
#     # comm should set the commutator of a and b to rhs
# end

# typeof(x * y)
# q = SymbolicUtils.Mul(Number, 2, OrderedDict(x => 1, y => 1))
# w = SymbolicUtils.Mul(Number, 2, Dict(y => 1, x => 1))

# SymbolicUtils.jl does not have non-commuting symbolic types implemented.
# We can use the following workaround:
#
# 1. Define a new type for non-commuting symbolic types i.e. Tensors
# 2. Define a new type for multiplication of Tensors i.e. TensorProduct which preserves order
#// 3. This TensorProduct (replacing Mul) should then interface with Add and Pow from SymbolicUtils.jl
# Note: Add requires keys be subtypes of Number, so we can't use TensorProduct as a key in Add
# Thus, 3. becomes Define TensorAdd and TensorPow to interface with TensorProduct
# I am defining the BraKet Algebra. 
# @syms c d
# SymbolicUtils.Add(Number, 2, Dict(c => 1, d => 1))

# The Plan:
# Given a commutation relation:
# [a_p, a_q'] = i δ_pq
# we can define a rule that recursively simplifies an expression like:
# ⟨q|a_p a_q' |p⟩ = ⟨q|(a_q'a_p + i δ_pq)|p⟩ = ⟨q|a_q'a_p|p⟩ + i⟨q|δ_pq|p⟩ = ⟨0|0⟩+ i ⟨p|p⟩ = 1 + i
#                       ^^^ 
#                       a_q' annihilates the state q
