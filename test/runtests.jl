using QFT
using Symbolics
using Test

v = vacuum()
@operators ScalarField a
@syms p q k l
@syms δ(p) E(p)
a_p, a_q, a_k, a_l = a(p), a(q), a(k), a(l)
sym_pi = SymbolicUtils.Sym{Number}(:π)
twopi = 2 * sym_pi

include("BraKets/test_Bra.jl")
include("BraKets/test_Ket.jl")

include("Integrals/test_Integrals.jl")

include("Op_Ket_Interactions/test_Commutators.jl")
include("Op_Ket_Interactions/test_InnerProducts.jl")
include("Op_Ket_Interactions/test_Interactions.jl")
include("Op_Ket_Interactions/test_NormalOrdering.jl")

include("Operators/test_AbstractOperator.jl")
include("Operators/test_Operator.jl")
include("Operators/test_OperatorPower.jl")
include("Operators/test_OperatorProduct.jl")
include("Operators/test_OperatorTerm.jl")


# Neater way to include all test files in the test folder
# but doesn't run on github actions as Github can't find "./test"
# To fix this we could use the full path to the test folder

# folders = setdiff(readdir("."), ["runtests.jl"])
# test_files = []
# # Step 2: Filter out files in each folder that are not .jl
# for folder in folders
#     push!(test_files, filter(x -> endswith(x, ".jl"), readdir("./test/" * folder, join=true))...)
# end
# test_files
# # Step 3: Filter out files that are not in the format test_*.jl
# test_files = filter(x -> contains(x, "test_"), test_files)
# # Step 4: include each file
# # @testset "QFT" begin
#     for file in test_files
#         include("../" * file)
#     end
# # end

# To run the tests in a terminal, type:
# julia --project=. test/runtests.jl
# should take ⪅ 1 min