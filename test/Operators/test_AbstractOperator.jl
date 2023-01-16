@operator ScalarField a
@operators DiracField b c


@syms p q 
@operator ScalarField a
a_p = a(p)
a(-2p + q)
operation(a_p)
arguments(a_p)

nameof(AbstractOperator{ScalarField})
@syms f(p,q)
typeof(f(p,q))


substitute(a(p + q)', Dict(p => q))
operation(a(p + q)')(arguments(a(p - q)')...)
similarterm(a(p + q)', a, (q,))

istree(a(p))
exprhead(a(p))
operation(a(p))
similarterm(a(p)', a, (q,))
macro typeof(expr)
    return :(typeof($(esc(expr))))
end
@typeof q
# @syms f(p,q)
# typeof(f(p,q))
# typeof(f(p,q))
# fieldnames(typeof(f(p,q)))
# fpq = SymbolicUtils.Term{Number,Nothing}(f, (p,q,p), nothing, 0x0)
# substitute(fpq, Dict(p => q))
# istree(fpq)
# exprhead(fpq)
# operation(fpq)
# arguments(fpq)


test = a(p)'
substitute(test, Dict(p => q))
one(Operator)
Operator()
Ket()
a(k)' * Ket()


function subs(expr, dict; fold=true)
    haskey(dict, expr) && return dict[expr]
    println(expr)
    if istree(expr)
        op = subs(operation(expr), dict; fold=fold)
        if fold
            canfold = !(op isa SymbolicUtils.Symbolic)
            args = map(unsorted_arguments(expr)) do x
                x′ = subs(x, dict; fold=fold)
                canfold = canfold && !(x′ isa SymbolicUtils.Symbolic)
                x′
            end
            canfold && return op(args...)
            args
        else
            args = map(x->substitute(x, dict, fold=fold), unsorted_arguments(expr))
        end
        println("args: ",similarterm(expr,
        op,
        args,
        symtype(expr);
        metadata=metadata(expr)))
        return similarterm(expr,
                    op,
                    args,
                    symtype(expr);
                    metadata=metadata(expr))
    else
        return expr
    end
end
subs(a(p+q)', Dict(p => q))