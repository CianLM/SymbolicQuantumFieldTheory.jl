module QFT

import Base: +, -, *, /, //, \, ^, ImmutableDict, adjoint
import Base: cmp, isless
import Base: length, hash, iterate, firstindex, getindex, setindex!, lastindex
import Base: reverse
import Base: one
import Base: nameof # for AbstractOperator

using BenchmarkTools
using Symbolics
import SymbolicUtils
using SymbolicUtils.Rewriters: RestartedChain, Fixpoint
import SymbolicUtils.Code
using TermInterface
using Metatheory
using Metatheory.Library
using LaTeXStrings
using Latexify
# using LinearAlgebra: I
# I
# one(::Type{<:Operator}) = Operator(:I,())
# one(Operator)


import TermInterface: istree, exprhead, operation, arguments, similarterm

# using Pkg
# Pkg.resolve()

SymorNum = Union{SymbolicUtils.Symbolic,Number}

Ket()
Ket((:a,:b,:a))

adjoint(x::Ket) = Bra(x.name)


adjoint(x::Bra) = Ket(x.name)

macro kets(names...)
    defs = map(names) do name
        :($(esc(name)) = Ket($(Expr(:quote, name))))
    end
    return Expr(:block, defs...,
        :(tuple($(map(x -> esc(x), names)...))))
end

macro bras(names...)
    defs = map(names) do name
        :($(esc(name)) = Bra($(Expr(:quote, name))))
    end
    return Expr(:block, defs...,
        :(tuple($(map(x -> esc(x), names)...))))
end

+(a::Ket, b::Ket) = KetState(Dict(a => 1, b => 1))
-(a::Ket, b::Ket) = KetState(Dict(a => 1, b => -1))
*(a::Ket, b::SymorNum) = KetState(Dict(a => b))
*(b::SymorNum, a::Ket) = KetState(Dict(a => b))
/(a::Ket, b::SymorNum) = KetState(Dict(a => 1 / b))

*(a::Ket, b::SymbolicUtils.Symbolic) = KetState(Dict(a => b))
*(a::SymbolicUtils.Symbolic, b::Ket) = KetState(Dict(b => a))
/(a::Ket, b::SymbolicUtils.Symbolic) = KetState(Dict(a => 1 / b))


end

# Ket(:q,:p) for a scalar field
# Ket((:q,:r),(:p,:s)) for a vector/spinor field due to the polarisation vector.
# To reconcile this, rather than defining a new type for spinors, we can just
qp = Ket((:q, :p, :p))
pq = Ket((:p, :q))
(im * qp + √5pq) / 2
c = (im + √3) / 2
c'c ≈ 1

@kets ψ ϕ χ
@syms a b c
(a + √5)^5 * ψ
expand((a + √5)^5)
# The overarching vision:
"""md
- Given an initial state |ψ⟩, one can calculate:
    - aₚ ... aₖ |ψ⟩ -> |ϕ⟩
    - ⟨ψ| aₖ' ... aₚ' -> ⟨ϕ|
    - ⟨ϕ| aₖ' ... aₚ' |ψ⟩ -> c (symbolic or not) ∈ 𝐂 (with commutation relations)
- One can then calculate amplitudes in the Dyson expansion with
    - ⟨f|ℋ(x)|i⟩ (first order)
    - ⟨f|ℋ(x)ℋ(y)|i⟩ (second order)
    - etc...
- These amplitudes each correspond to a Feynman diagram
- We therefore have symbolic scattering amplitudes for any scattering process requiring only:
    - the initial state |ψ⟩
    - the final state |ϕ⟩
    - the Hamiltonian ℋ(x) (or the Lagrangian ℒ(x) using a Legendre transform ℋ = π ∂ₜϕ - ℒ)
    - the commutation relations
"""