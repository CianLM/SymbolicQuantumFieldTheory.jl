normalorder(x::SymorNum) = x
normalorder(x::Operator) = x
normalorder(x::OperatorPower) = x
function normalorder(x::OperatorProduct)
    # TODO: Add in total ordering of symbols to ensure that the normal ordering is unique.
    if isnormalordered(x)
        return x
    elseif length(x) == 2
        return x[2].adjoint ? x[2] * x[1] + comm(x[1], x[2]) : x
    elseif x[1].adjoint
        return x[1] * normalorder(x[2:end])
    else
        return normalorder(x[2:end] * x[1] + comm(x[1], x[2:end]))
    end
end

function symbolorder(x::OperatorProduct)
    if !isnormalordered(x)
        return "Normal order first."
    end
    # Find the index at which the daggers end
    i = findfirst(o -> !o.adjoint, x.operators)
    y = Union{Operator,OperatorPower}[]
    # Sort the symbols before the daggers by the operators indices
    append!(y,
        sort(x[1:i-1].operators, by = o -> o isa Operator ? Symbol(o.indices[1]) : Symbol(o.operator.indices[1]))
    )
    # Sort the symbols after the daggers by the operators indices
    append!(y,
        sort(x[i:end].operators, by = o -> o isa Operator ? Symbol(o.indices[1]) : Symbol(o.operator.indices[1]))
    )
    return OperatorProduct(y)
end


function normalorder(x::OperatorTerm)
    d = Dict{OperatorSym,SymorNum}()
    for (k, v) in x.terms
        nk = normalorder(k)
        if nk isa OperatorTerm
            for (kn, vn) in nk.terms
                d[kn] = get(d, kn, 0) + v * vn
            end
        else
            d[nk] = get(d, nk, 0) + v
        end
    end
    return isempty(d) ? 0 : OperatorTerm(d)
end

isnormalordered(x::SymorNum) = true
isnormalordered(x::Operator) = true
isnormalordered(x::OperatorPower) = true
function isnormalordered(x::OperatorProduct)
    return all([o.adjoint == x[1].adjoint for o in x]) || (x[1].adjoint ? isnormalordered(x[2:end]) : false)
end
isnormalordered(x::OperatorTerm) = all(isnormalordered, keys(x.terms))