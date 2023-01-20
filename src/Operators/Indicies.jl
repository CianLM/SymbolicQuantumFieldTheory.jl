# struct Index1
#     symbolic::SymbolicUtils.Symbolic
# end
# abstract type Index2 end

# struct SpinorIndex1 <: Index2
#     symbolic::SymbolicUtils.Symbolic
# end

# struct Momentum1 <: Index2
#     symbolic::SymbolicUtils.Symbolic
# end

# # define @spinorIndex analogously to @syms from SymbolicUtils
# macro spinorIndex(indicies)


# end

# twopi
# @field DiracField
# @operators DiracField b c
# @comm [b(p,r), c(q,s)'] = 2 * E(p) * twopi^3 * δ(p - q) * (r == s)
# comm(b(p,r), c(q,s)')

# @syms p q
# @syms r s
# b(p,q)' * c(q,s)' * v

# @field ScalarField
# @operator ScalarField abs
# @comm [a(r), a(l)'] = δ(r - l)
# comm(a(p), a(l)')
# l
# r

# function Kronecker(a::SymbolicUtils.Symbolic, b::SymbolicUtils.Symbolic)
#     (a - b isa Number && a - b == 0) ? 1 : 0
# end

# @syms δ(a)