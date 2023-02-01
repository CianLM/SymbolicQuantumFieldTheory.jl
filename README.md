# SymbolicQuantumFieldTheory.jl

[![Build Status](https://github.com/CianLM/QFT.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/CianLM/QFT.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Symbolic Quantum Field Theory in Julia

This package is in active development and is not production ready. Feel free to reach out with suggestions/issues.

## Basic Syntax

```julia
using QFT
using Symbolics
@operator ScalarField a
@syms p q
# then we can do
comm(a(p),a(q)')
normalorder(a(p) * a(q)')
a(p)'^2 * a(q)' * vacuum()
ℋ = E(q) * a(q)' * a(q)
integrate(ℋ * a(p)', q)
```

