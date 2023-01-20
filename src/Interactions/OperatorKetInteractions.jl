vacuum() = Ket()

function *(a::Union{Operator,OperatorPower}, b::Ket)
    if a == one(Operator)
        return b
    elseif !a.adjoint && b == vacuum()
        # a∣0⟩ = 0
        return 0
    elseif !a.adjoint
        # for i in b.indices 
        b_op = b.op
        return normalorder(a * b_op) * vacuum()
    elseif a.adjoint && b == vacuum()
        # aₚ^† ∣0⟩ = ∣p⟩
        return Ket(a)
    else
        # aₚ^† ∣q⟩ = ∣p; q⟩
        return Ket(a * b.op)
    end
end

function *(a::OperatorProduct, b::Ket)
    if !a[end].adjoint && b == vacuum()
        # a∣0⟩ = 0
        return 0
    end
    if isnormalordered(a)
        return Ket(a * b.op)
    else
        # Otherwise, we need to do some normal ordering
        return normalorder(a * b.op) * vacuum()
    end
end

function *(a::OperatorTerm, b::Ket)
    d = Dict{Ket,SymorNum}()
    println(a)
    for (ka, va) in a.terms
        applied = ka * b
        # print(typeof(ka), " ", typeof(b), " ", typeof(applied), " ")
        # println("$ka * $b = $applied")
        if applied isa Ket
            # println("$applied is a Ket")
            d[applied] = get(d, applied, 0) + va
        elseif applied isa KetState
            # println("$applied is a KetState")
            for (kb, vb) in applied
                d[kb] = get(d, kb, 0) + va * vb
            end
        else
            # println("Unexpected Term: $applied is neither a Ket nor a KetState")
        end
    end
    return isempty(d) ? 0 : KetState(d)
end

function *(a::OperatorTerm, b::KetState)
    # Uses OperatorTerm * Ket Multiplication
    d = Dict{Ket,SymorNum}()
    for (kb, vb) in b.states
        applied = a * kb
        if applied isa Ket
            d[applied] = get(d, applied, 0) + vb
        elseif applied isa KetState
            for (kc, vc) in applied.states
                d[kc] = get(d, kc, 0) + vb * vc
            end
        end
    end
    return isempty(d) ? 0 : KetState(d)
end

*(a::T where {T<:OperatorSym}, b::KetState) = OperatorTerm(Dict{OperatorSym,SymorNum}(a=>1)) * b

# Bras
*(a::Bra, b::T where {T<:OperatorSym}) = (b' * a')'
*(a::Bra, b::OperatorTerm) = (b' * a')'
*(a::BraState, b::T where {T<:OperatorSym}) = (b' * a')'
*(a::BraState, b::OperatorTerm) = (b' * a')'