struct QFTIntegral <: OperatorSym
    # This struct represents a symbolic integral defining an important quantity.
    # E.g. the Hamiltonian, the Lagrangian, the energy, etc.
    # The integral is defined by an integrand and a set of variables to be integrated over.
    # The integrand is a function of the variables, and we assume infinite bounds always.
    integrand::OperatorTerm
    variables::SymbolicUtils.Sym

    function QFTIntegral(integrand::OperatorTerm, variable::SymbolicUtils.Sym{Number,Nothing})
        # Attempt to integrate the integrand over the variables.
        # If the integrand is not integrable, then return the symbolic instance here.
        new(integrand, variable)
    end
end

function Base.show(io::IO, integral::QFTIntegral)
    print(io, "∫d$(integral.variables) ($(integral.integrand)) ")
end
# ipynb printing using latex
function Base.show(io::IO, ::MIME"text/latex", integral::QFTIntegral)
    print(io, "\\int \\mathrm{d$(integral.variables)} \\left($(integral.integrand)\\right) ")
end

function integrate(integrand::OperatorTerm, k::SymbolicUtils.Sym)
    no_int = normalorder(integrand)
    integrated = 0
    for (term, coeff) in no_int.terms
        coeff = simplify(coeff)
        # Search for δ(p ± k) in coeff
        params = SymbolicUtils.Chain([r,r_c,r_lrc,rm,rm_c,rm_lrc])(coeff)
        # print comma separated coeff, params, Term
        printstyled("Coeff: $coeff, Params: $params, Term: $term \n", color=:grey)

        if params !== coeff #i.e. a match has been found
            printstyled("Found $params in $coeff \n", color=:green)
            k_replacement = Symbolics.solve_for(params ~ 0, k)
            printstyled("Replacing $k with $k_replacement \n", color=:green)
            integrated_coeff = substitute(coeff, Dict(
                Delta(params) => 1,
                k => k_replacement
            ))
            printstyled("Integrated coefficient is $integrated_coeff \n", color=:green)
            cterm = OperatorTerm(term)
            for op in keys(cterm.terms)
                if op != one(Operator) && SymbolicUtils.Sym{Number}(op.indices[1]) - k isa Number && SymbolicUtils.Sym{Number}(op.indices[1]) - k == 0
                    delete!(cterm.terms, op)
                    cterm[Operator(op.name,(Symbol(k_replacement),), op.adjoint )] = 1
                    printstyled("Replacing $k with $k_replacement in $op \n", color=:green)
                end
            end
            printstyled("Final term is $cterm \n", color=:green)
            integrated += integrated_coeff * cterm
        else
            printstyled("No match found in $coeff\n", color=:red)
            integrated += coeff * term

        end
    end
    return integrated
end

function integrate(integrand::KetState, k::SymbolicUtils.Sym)

end

function integrate(integrand::Ket, k::SymbolicUtils.Sym)
    # Reduce 
end


@syms p q E(p) m
# Make π symbolic
# ℋ 
twopi = 2*SymbolicUtils.Sym{Number}(:π)
# To get how to type a symbol in Julia one can run the function below
ℋ = 1/(twopi) * E(q) * a_q' * a_q
t = integrate(ℋ*a_p' * v,q)

typeof(t)
substitute([values(t.states)...][1], Dict(
    E(p) => √(m^2 + p^2)
))

typeof.(values(t.states))

a = a_q' * (a_p' * a_q + 2π*Delta(p - q))
b = one(Operator) * p*Delta(p - q)
integrate(a, q) * v
integrate(b, p)

Symbolics.solve_for(q - p ~ 0, q)

# Define addition and subtraction of integrals internally and with OperatorTerms
# Then move to interactions with Kets and Ket states
