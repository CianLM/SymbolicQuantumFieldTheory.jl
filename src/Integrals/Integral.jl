struct UnevaluatedIntegral <: OperatorSym
    # This struct represents a symbolic integral defining an important quantity.
    # E.g. the Hamiltonian, the Lagrangian, the energy, etc.
    # The integral is defined by an integrand and a variable to be integrated over.
    # The integrand is a function of the variable, and we assume infinite bounds always.
    integrand::OperatorTerm
    variable::SymbolicUtils.Sym

    function UnevaluatedIntegral(integrand::SymorNum, variable::SymbolicUtils.Sym{Number,Nothing})
        new(OperatorTerm(integrand), variable)
    end

    function UnevaluatedIntegral(integrand::OperatorTerm, variable::SymbolicUtils.Sym{Number,Nothing})
        new(integrand, variable)
    end

    function UnevaluatedIntegral(integrand::T where {T <: OperatorSym}, variable::SymbolicUtils.Sym{Number,Nothing})
        new(OperatorTerm(integrand), variable)
    end

    function UnevaluatedIntegral(integrand::Ket, variable::SymbolicUtils.Sym{Number,Nothing})
        Ket( new(OperatorTerm(integrand.op), variable) )
    end

    function UnevaluatedIntegral(integrand::Bra, variable::SymbolicUtils.Sym{Number,Nothing})
        Bra( new(OperatorTerm(integrand.op), variable) )
    end

    function UnevaluatedIntegral(integrand::KetState, variable::SymbolicUtils.Sym{Number,Nothing})
        # Create a KetState with coefficients 1 and the operator being the UnevaluatedIntegral
        println([@which v * UnevaluatedIntegral(k, variable) for (k,v) in integrand.states])
        dict = Dict{Ket,SymorNum}(
            Ket(v * UnevaluatedIntegral(k.op, variable)) => 1 for (k, v) in integrand.states
        )
        return KetState(dict)
    end

end

function Base.show(io::IO, integral::UnevaluatedIntegral)
    print(io, "∫d$(integral.variable) ($(integral.integrand)) ")
end
# ipynb printing using latex
function Base.show(io::IO, ::MIME"text/latex", integral::UnevaluatedIntegral)
    print(io, "\\int \\mathrm{d$(integral.variable)} \\left($(integral.integrand)\\right) ")
end

function integrate(ks::KetState)
    sum([ v * k.op isa UnevaluatedIntegral ? integrate(v * k.op) * vacuum() : error("not an UnevaluatedIntegral") for (k,v) in ks.states])
end
function integrate(ui::UnevaluatedIntegral)
    return integrate(ui.integrand, ui.variable)
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
            printstyled("Found $params deps $k in $coeff \n", color=:green)
            k_replacement = Symbolics.solve_for(params ~ 0, k)
            printstyled("Replacing $k with $k_replacement \n", color=:green)
            integrated_coeff = substitute(coeff, Dict(
                δ(params) => 1,
                k => k_replacement
            ))
            subbed_term = substitute(term, Dict(k => k_replacement))
            printstyled("Final term is $subbed_term \n", color=:green)
            integrated += integrated_coeff * subbed_term
        else
            printstyled("No match found in $coeff\n", color=:red)
            integrated += UnevaluatedIntegral(coeff * term, k)
        end
    end
    return integrated
end

function integrate(integrand::Ket, k::SymbolicUtils.Sym)
    return Ket(integrate(integrand.op, k))
end

function integrate(integrand::KetState, k::SymbolicUtils.Sym)
    return sum([integrate(v * key.op, k) * vacuum() for (key,v) in integrand.states])
end

function integrate(integrand::Bra, k::SymbolicUtils.Sym)
    return Bra(integrate(integrand.op, k))
end

function +(a::UnevaluatedIntegral, b::UnevaluatedIntegral)
    if a.variable - b.variable isa Number && a.variable - b.variable == 0
        return UnevaluatedIntegral(a.integrand + b.integrand, a.variable)
    else
        return OperatorTerm(a) + OperatorTerm(b)
    end
end
+(a::UnevaluatedIntegral, b::SymorNum) = UnevaluatedIntegral(a.integrand + b, a.variable)
+(a::SymorNum, b::UnevaluatedIntegral) = UnevaluatedIntegral(a + b.integrand, b.variable)
+(a::UnevaluatedIntegral, b::OperatorSym) = UnevaluatedIntegral(a.integrand + b, a.variable)
+(a::OperatorSym, b::UnevaluatedIntegral) = UnevaluatedIntegral(b.integrand + a, b.variable)
+(a::UnevaluatedIntegral, b::OperatorTerm) = UnevaluatedIntegral(a.integrand + b, a.variable)
+(a::OperatorTerm, b::UnevaluatedIntegral) = UnevaluatedIntegral(b.integrand + a, b.variable)
α*one(Operator) + Bra() * Ket()


-(a::UnevaluatedIntegral) = UnevaluatedIntegral(-a.integrand, a.variable)
-(a::UnevaluatedIntegral, b::UnevaluatedIntegral) = a + (-b)


*(a::UnevaluatedIntegral, b::Ket) =Ket(UnevaluatedIntegral(a.integrand * b.op, a.variable))
*(a::Bra, b::UnevaluatedIntegral) =Bra(UnevaluatedIntegral(a.op * b.integrand, b.variable))

*(a::UnevaluatedIntegral, b::SymorNum) = UnevaluatedIntegral(a.integrand * b, a.variable)
*(a::SymorNum, b::UnevaluatedIntegral) = UnevaluatedIntegral(a * b.integrand, b.variable)

*(a::UnevaluatedIntegral, b::OperatorSym) = UnevaluatedIntegral(a.integrand * b, a.variable)
*(a::OperatorSym, b::UnevaluatedIntegral) = UnevaluatedIntegral(a * b.integrand, b.variable)

*(a::UnevaluatedIntegral, b::OperatorTerm) = UnevaluatedIntegral(a.integrand * b, a.variable)
*(a::OperatorTerm, b::UnevaluatedIntegral) = UnevaluatedIntegral(a * b.integrand, b.variable)

x = UnevaluatedIntegral(a_p',q)
UnevaluatedIntegral(a_p' * a_p * a_q', p)
UnevaluatedIntegral(v, p)
UnevaluatedIntegral(a_q' * a_p' * a_p' * v, p)
x * a_q'
a_q' * x
x * (5 * a_q')
5 * a_q' * x
5 * x
x * α

e = ℯ
ϕ = UnevaluatedIntegral( a(p) * e^(-im * p) + a(p)' * e^(im * p), p)
ϕ

jj = UnevaluatedIntegral(a_q' * v + a_p' * v, k)
@typeof 5*UnevaluatedIntegral(a_q', k)
j = UnevaluatedIntegral(p * a_p * a_k' * a_q' * v, p)
j.states
integrate(j)
integrate(jj)



tt = UnevaluatedIntegral(x + x + 2x,q)




integrate(a_q' * a_q * a_p' * v, q)

@syms p q E(p) m
# Make π symbolic
# ℋ 
twopi = 2*SymbolicUtils.Sym{Number}(:π)
# To get how to type a symbol in Julia one can run the function below
ℋ = 1/(twopi) * E(q) * a(q)' * a(q)
t = integrate(ℋ * a(p)', q) * v

t.states


substitute(a_q', Dict(q => p))

p





typeof(t)
substitute([values(t.states)...][1], Dict(
    E(p) => √(m^2 + p^2)
))

typeof.(values(t.states))
aa = a_q' * (a_p' * a_q + 2π*δ(p - q))
b = one(Operator) * p*δ(p - q)
c = 5 * a(p)' * a(q)
integrate(aa, q)
integrate(b, p) * v
integrate(c, p)

Symbolics.solve_for(q - p ~ 0, q)

istree(one(Operator))


# Define addition and subtraction of integrals internally and with OperatorTerms
# Then move to interactions with Kets and Ket states
