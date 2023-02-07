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




folders = setdiff(readdir("./test"), ["runtests.jl"])

test_files = []
# Step 2: Filter out files in each folder that are not .jl
for folder in folders
    push!(test_files, filter(x -> endswith(x, ".jl"), readdir("./test/" * folder, join=true))...)
end
test_files

# Step 3: Filter out files that are not in the format test_*.jl
test_files = filter(x -> contains(x, "test_"), test_files)

# Step 4: include each file
# @testset "QFT" begin
    for file in test_files
        include("../" * file)
    end
# end

# To run the tests in a terminal, type:
# julia --project=. test/runtests.jl
# should take ⪅ 1 min

# Pre-commit hook
# Use grep to find uncommented println statements. i.e. println not preceeded by a # earlier in the line
# grep -r -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' src | grep println
# Then, if the line ends with a '#' do not include it. Use regex
# grep -r -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' src | grep println | grep -v '#$'