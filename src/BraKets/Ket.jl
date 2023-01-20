struct Ket <: BraKet
    op::OperatorSym

    Ket() = new(one(Operator))
    # Define a function to create a Ket from an operator
    # to be called when applying an operator to the vacuum
    # We are actually doing a_p * ∣0⟩ = ∣p⟩ not ∣a_p⟩.
    Ket(op::OperatorSym) = new(op) # Not to be exported or used directly

end

function Base.show(io::IO, s::Ket)
    if s.op == one(Operator)
        print(io, "|0⟩")
        return
    end
    # print(io, "∣", join(s.name, "; "), "⟩")
    # Print np for n occurances of p in s.name
    # Vacuum printing
    print(io, s.op, "|0⟩")
end

function Base.show(io::IO, ::MIME"text/latex", s::Ket)
    if s.op == one(Operator)
        print(io, "\\left|0\\right\\rangle")
        return
    end
    # print(io, "\\left|", join(s.name, "; "), "\\right\\rangle")
    # Print np for n occurances of p in s.name
    # Vacuum printing
    print(io, s.op, "\\left|0\\right\\rangle")
end

Base.:(==)(a::Ket, b::Ket) = normalorder(a.op) == normalorder(b.op)

begin "TermInterface"
    function istree(x::Ket)
        return true
    end

    function exprhead(x::Ket)
        return :call
    end

    function operation(x::Ket)
        return Ket
    end

    function arguments(x::Ket)
        return [x.op]
    end
    function similarterm(t::Ket, f, args, symtype=Ket; metadata=nothing, exprhead=exprhead(t))
        return f(args...)
    end

end

function Base.hash(x::Ket, h::UInt=UInt(0))
    h = hash(normalorder(x.op), h)
    return h
end