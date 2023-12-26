module QFT

import Base: +, -, *, /, //, \, ^, ImmutableDict, adjoint
import Base: cmp, isless
import Base: length, hash, iterate, firstindex, getindex, setindex!, lastindex
import Base: reverse
import Base: one
import Base: nameof # for AbstractOperator
import Base: convert # for Integral Int -> Operator
import Base: display

using BenchmarkTools
using Symbolics
import SymbolicUtils
using SymbolicUtils.Rewriters: RestartedChain, Fixpoint
import SymbolicUtils.Code
using TermInterface
using LaTeXStrings
using Latexify

using MacroTools

import TermInterface: istree, exprhead, operation, arguments, similarterm, metadata

SymorNum = Union{SymbolicUtils.Symbolic,Number}
abstract type OperatorSym end
# abstract type OperatorPowers <: OperatorSym end
abstract type BraKet end
abstract type State end

abstract type Field end
abstract type ScalarField <: Field end

export Field, ScalarField
# α β γ δ ε ζ η θ ι κ λ μ ν ξ ο :π ρ σ τ υ φ χ ψ ω
# Italic Greek
# 𝛼 𝛽 𝛾 𝛿 𝜀 𝜁 𝜂 𝜃 𝜄 𝜅 𝜆 𝜇 𝜈 𝜉 𝜊 𝜋 𝜌 𝜍 𝜎 𝜏 𝜐 𝜑 𝜒 𝜓 𝜔
# ᵅᵝᵡᵟᵋᵠᶿ
# ? == TODO
# ? Add anticommutator support and add metadata to fields to make ^2n vanish for fermions
# ? Fix integration of OperatorSyms and Integral Interactions
# ? Add Spinors

export @operators, @operator, @field, @comm
include("Operators/AbstractOperator.jl")
include("Operators/Operator.jl")
include("Operators/OperatorPower.jl")
include("Operators/OperatorProduct.jl")
include("Operators/OperatorTerm.jl")

export vacuum
include("BraKets/Bra.jl")
include("BraKets/Ket.jl")
include("BraKets/KetState.jl")
include("BraKets/BraState.jl")

export comm, normalorder, symbolorder, isnormalordered
include("Interactions/Commutators.jl")
include("Interactions/NormalOrdering.jl")
include("Interactions/OperatorKetInteractions.jl")
include("Interactions/InnerProducts.jl")

export integrate
include("Integrals/IntegrationRules.jl")
include("Integrals/Integral.jl")

include("BraKets/Adjoints.jl")

using Revise
using Metatheory
using Latexify
import Base: hash, reverse, iterate, firstindex, getindex, setindex!, lastindex
import Base:  one, convert, length, *, +, -, /, ^
import SymbolicUtils
SymorNum = Union{SymbolicUtils.Symbolic,Number}

export Index, Tensor, TensorProduct, TensorSum
export @DefineTensor, @Index, @Indices, @Tensor, @Tensors
export raise, lower, raiseAll, lowerAll, contract_metric, relabel
export g, ∂, Derivative, MetricTensor
include("Tensors/Index.jl")
include("Tensors/AbstractTensor.jl")
include("Tensors/Tensor.jl")
include("Tensors/TensorProduct.jl")
include("Tensors/TensorSum.jl")
1


# testing
# @field James
# @operators James f
# @syms a b c
# @comm [f(a),f(b)'] = f(a)*f(b)'
# comm(f(c),f(a)')
# comm(f(a),f(b)' * f(c)')

# comm(f(a)' * f(b), f(b)' * f(a))
# normalorder(t)

# Define latexify for the exp function



ISSUE_LINK = "https://github.com/CianLM/SymbolicQuantumFieldTheory.jl/issues/new"
end