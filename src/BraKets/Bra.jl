struct Bra
    name::Tuple{Vararg{Symbol}}

    Bra() = new(tuple())
    Bra(name::Symbol) = new(tuple(name))
    Bra(name::String) = new(Symbol(tuple(Symbol(name))))
    Bra(name::Tuple{Vararg{Symbol}}) = new(name)

end

function Base.show(io::IO, s::Bra)
    if length(s.name) == 0
        print(io, "⟨0|")
        return
    end
    print(io,"⟨")
    for p in unique(s.name)
        c = count(x -> x == p, s.name)
        c > 1 ? print(io, c, p) : print(io, p)
        # If p is not the last element in unique(s.name), print a space
        p != unique(s.name)[end] && print(io, "; ")
    end
    print(io, "|")
end

begin "TermInterface"
    function istree(x::Bra)
        return false
    end

    function exprhead(x::Bra)
        return :call
    end
end



+(a::Bra, b::Bra) = BraState(Dict(a => 1, b => 1))
-(a::Bra, b::Bra) = BraState(Dict(a => 1, b => -1))
*(a::Bra, b::SymorNum) = BraState(Dict(a => b))
*(b::SymorNum, a::Bra) = BraState(Dict(a => b))
/(a::Bra, b::SymorNum) = BraState(Dict(a => 1 / b))

*(a::Bra, b::SymbolicUtils.Symbolic) = BraState(Dict(a => b))
*(a::SymbolicUtils.Symbolic, b::Bra) = BraState(Dict(b => a))
/(a::Bra, b::SymbolicUtils.Symbolic) = BraState(Dict(a => 1 / b))