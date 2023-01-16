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

using MacroTools

import TermInterface: istree, exprhead, operation, arguments, similarterm, metadata

SymorNum = Union{SymbolicUtils.Symbolic,Number}
abstract type OperatorSym end
# abstract type OperatorPowers <: OperatorSym end
abstract type BraKet end
abstract type State end

abstract type Field end
abstract type ScalarField <: Field end


# α β γ δ ε ζ η θ ι κ λ μ ν ξ ο :π ρ σ τ υ φ χ ψ ω
# Italic Greek
# 𝛼 𝛽 𝛾 𝛿 𝜀 𝜁 𝜂 𝜃 𝜄 𝜅 𝜆 𝜇 𝜈 𝜉 𝜊 𝜋 𝜌 𝜍 𝜎 𝜏 𝜐 𝜑 𝜒 𝜓 𝜔
# ᵅᵝᵡᵟᵋᵠᶿ



end