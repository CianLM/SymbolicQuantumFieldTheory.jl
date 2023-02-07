@testset "Operator" begin
    @syms p q 
    @operator ScalarField a
    a_p = a(p)
    a(-2p + q)
    operation(a_p)
    arguments(a_p)

    @test substitute(a(p + q), Dict(p => q)) == a(2q)

    @test istree(a(p)) == true
    @test operation(a(p)) == a
    @test similarterm(a(p), a, (q,)) == a(q)
end


# macro operator(names...)
#     defs = map(names) do name
#         # Check each name is of the form a_p
#         if length(string(name)) < 3 || string(name)[2] != '_'
#             error("Operator name must be of the form a_p (multiple indices allowed i.e. a_pq)")
#         end

#         # Split the name into the operator name and the index
#         opname, indices = split(string(name), "_")
#         indices = Tuple(Symbol.(split(indices, "")))
#         :($(esc(name)) = Operator($(Expr(:quote, Symbol(opname))), $(Expr(:quote, indices))))
#     end
#     return Expr(:block, defs...,
#         :(tuple($(map(x -> esc(x), names)...))))
# end


#! ### TESTING ###
# @operator aₚ aₖ aₐ aₑ aₕ aᵢ aⱼ aₖ aₗ aₘ aₙ aₒ aₚ aᵣ aₛ aₜ aᵤ aᵥ aₓ
# # All possible alphabetical subscripts:
# # ₐ ᵦ ᵪ ₑ ᵧ ₕ ᵢ ⱼ ₖ ₗ ₘ ₙ ₒ ₚ ᵩ ᵣ ᵨ ₛ ₔ ₜ ᵤ ᵥ ₓ
# @operator a_p a_q a_k
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
# 1. Define a new type for non-commuting symbolic types i.e. Operators
# 2. Define a new type for multiplication of operators i.e. OperatorProduct which preserves order
#// 3. This OperatorProduct (replacing Mul) should then interface with Add and Pow from SymbolicUtils.jl
# Note: Add requires keys be subtypes of Number, so we can't use OperatorProduct as a key in Add
# Thus, 3. becomes Define OperatorAdd and OperatorPow to interface with OperatorProduct
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
