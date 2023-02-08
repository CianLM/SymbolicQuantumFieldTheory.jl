struct Bra <: BraKet
    op::OperatorSym

    Bra() = new(one(Operator))
    Bra(op::OperatorSym) = new(op) # Not to be exported or used directly
end

function Base.show(io::IO, s::Bra)
    if s.op == one(Operator)
        print(io, "⟨0|")
        return
    end
    print(io, "⟨0|", s.op)
    # print(io,"⟨")
    # for p in unique(s.name)
    #     c = count(x -> x == p, s.name)
    #     c > 1 ? print(io, c, p) : print(io, p)
    #     # If p is not the last element in unique(s.name), print a space
    #     p != unique(s.name)[end] && print(io, "; ")
    # end
    # print(io, "|")
end
@latexrecipe function f(x::Bra)
    env --> :equation
    cdot --> false
    # print(io,"\\left\\langle")
    # for p in unique(s.name)
    #     c = count(x -> x == p, s.name)
    #     c > 1 ? print(io, c, p) : print(io, p)
    #     # If p is not the last element in unique(s.name), print a space
    #     p != unique(s.name)[end] && print(io, "; ")
    # end
    return Expr(:call, :*, "\\left\\langle 0\\right|", x.op == one(Operator) ? "" : x.op)
end
Base.show(io::IO, ::MIME"text/latex", x::Bra) = print(io, "\$\$ " * latexify(x) * " \$\$")



Base.:(==)(a::Bra, b::Bra) = a.op == b.op

begin "TermInterface"
    function istree(x::Bra)
        return true
    end

    function exprhead(x::Bra)
        return :call
    end

    function operation(x::Bra)
        return Bra
    end

    function arguments(x::Bra)
        return [x.op]
    end

    function similarterm(t::Bra, f, args, symtype; metadata=nothing)
        return f(args...)
    end
end
