macro comm(ex)
    MacroTools.@capture(ex, [a_, b_] = c_) || error("expected a commutation relation of the form [a(p), b(q)] = f(p,q)")
    println("[$a,$b] = $c")
    # println("$(Operator{field(eval(a))})")
    return quote
        function comm(l::Operator{field($a)}, r::Operator{field($b)})
            if $a == one(Operator{ScalarField}) || $b == one(Operator{ScalarField})
                println("one")
                return 0
            elseif ($a.name != l.name || $b.name != r.name) || ($a.name != r.name || $b.name != l.name)
                println($a.name,l.name,$b.name,r.name)
                return 0
            elseif l.adjoint == $a.adjoint && r.adjoint == $b.adjoint || l.adjoint == $b.adjoint && r.adjoint == $a.adjoint
                ai = $a.indices[1]
                bi = $b.indices[1]
                cc  = substitute($c, Dict(zip($a.indices, l.indices)) ∪ Dict(zip($b.indices, r.indices)))
                
                return (-1)^(Int(l.adjoint == $b.adjoint) + Int($a.name != r.name)) * cc
            else
                println("else")
                return 0
            end
        end
    end |> eval
end
@operators DiracField b c
@syms k
@comm [b(p),b(q)'] = E(p) * δ(p - q)
comm(b(k),b(k - q)')




MacroTools.@capture(ex, f_(xs__) where {T_} = body_) ||
  error("expected a function with a single type parameter")

@comm DiracField a b c


using MacroTools


exp = :([b(p), a(q)] = c)

dump(exp)
