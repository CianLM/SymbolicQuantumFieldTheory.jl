adjoint(x::Ket) = Bra(x.op)
adjoint(x::Bra) = Ket(x.op)
adjoint(a::KetState) = BraState(Dict{Bra,SymorNum}(k' => v' for (k, v) in a.states))
adjoint(a::BraState) = KetState(Dict{Ket,SymorNum}(k' => v' for (k, v) in a.states))

adjoint(a::Operator) = a == one(Operator) ? a : Operator{field(a)}(a.name, a.indices, !a.adjoint)
adjoint(x::OperatorPower) = OperatorPower(x.operator', x.power)

function adjoint(x::OperatorProduct)
    return OperatorProduct(OporPower[o' for o in reverse(x.operators)])
end

function adjoint(x::OperatorTerm)
    return OperatorTerm(Dict{OperatorSym,SymorNum}(k' => v' for (k, v) in x.terms))
end

adjoint(x::SymbolicUtils.Symbolic) = conj(x)
conj(x::SymbolicUtils.Symbolic) = x # ! Temporary 

adjoint(x::SymbolicUtils.Term) = operation(x) == exp ? exp(-arguments(x)...) : error("Adjoint of $x undefined.")
adjoint(x::UnevaluatedIntegral) = UnevaluatedIntegral(x.integrand', x.variable)