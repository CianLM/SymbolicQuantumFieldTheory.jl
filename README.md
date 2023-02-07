# SymbolicQuantumFieldTheory.jl

[![Build Status](https://github.com/CianLM/QFT.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/CianLM/QFT.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Symbolic Quantum Field Theory in Julia

This package is in active development and is not production ready. Feel free to reach out with suggestions/issues.

Documentation is under construction.

## Basic Syntax

```julia
using QFT
using Symbolics
@operator ScalarField a
@syms p q
```
where `a` is the name of the operator and `p` and `q` are the momenta.


We can use these objects with
```julia
comm(a(p),a(q)')
normalorder(a(p) * a(q)')
a(p)'^2 * a(q)' * vacuum()
ℋ = E(q) * a(q)' * a(q)
integrate(ℋ * a(p)', q)
```

## Defining a Custom Commutation Relation

We can define a custom commutation relation between operators in a field using a natural syntax with the `@comm` macro.

*Note*. To do this we need to
```julia
import QFT.comm
```
as the `comm` function will be overloaded with your custom relation.

Then,
```julia
@field YourField
@operators YourField b c
@comm [b(p), c(q)'] = f(p,q)
```
for any `f(p,q)`.
This defines the commutation relation such that the commutator is now given by
```julia
@syms k l 
comm(b(k), c(l)') # = f(k,l)
```
where Julia has replaced `p` and `q` with `k` and `l` appropriately. Multiple indices are also supported with `@comm [b(p,q), c(r,s)'] = f(p,q,r,s)`.