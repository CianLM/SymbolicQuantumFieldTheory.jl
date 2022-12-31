struct Ket
    name::Tuple{Vararg{Symbol}}

    Ket() = new(tuple())
    Ket(name::Symbol) = new(tuple(name))
    Ket(name::String) = new(tuple(Symbol(name)))
    Ket(name::Tuple{Vararg{Symbol}}) = new(name)
end

function Base.show(io::IO, s::Ket)
    if length(s.name) == 0
        print(io, "|0⟩")
        return
    end
    # print(io, "∣", join(s.name, "; "), "⟩")
    # Print np for n occurances of p in s.name
    print(io,"|")
    for p in unique(s.name)
        c = count(x -> x == p, s.name)
        c > 1 ? print(io, c, p) : print(io, p)
        # If p is not the last element in unique(s.name), print a space
        p != unique(s.name)[end] && print(io, "; ")
    end
    print(io, "⟩")
end
Ket((:q, :p, :p, :q))

begin "TermInterface"
    function istree(x::Ket)
        return false
    end

    function exprhead(x::Ket)
        return :call
    end
end