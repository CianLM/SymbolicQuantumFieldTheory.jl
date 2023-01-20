function *(a::Bra,b::Ket)
    # Assuming orthogonality (as holds in QFT) but not in general in other finite systems.
    if length(a.op) != length(b.op)
        return 0
    else
        return get(OperatorTerm(normalorder(a.op' * b.op)).terms, one(Operator), 0)
    end
end


function *(a::BraState,b::KetState)
    # return sum(va * vb for (ka,va) in a.states for (kb,vb) in b.states if ka' == kb)
    # refactor as empty sum angers the compiler
    s = 0
    for (ka,va) in a.states
        for (kb,vb) in b.states
            # println(ka' == kb, " ", ka, " ", kb, " ", va * vb)
            s += va * vb * (ka * kb)
        end
    end
    return s
end

*(a::BraState,b::Ket) = a * KetState(Dict{Ket,SymorNum}(b => 1))
*(a::Bra,b::KetState) = BraState(Dict{Bra,SymorNum}(a => 1)) * b