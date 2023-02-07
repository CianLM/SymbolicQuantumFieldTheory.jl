@operator ScalarField a
v = vacuum()
struct UnevaluatedIntegral <: OperatorSym
    # This struct represents a symbolic integral defining an important quantity.
    # E.g. the Hamiltonian, the Lagrangian, the energy, etc.
    # The integral is defined by an integrand and a variable to be integrated over.
    # The integrand is a function of the variable, and we assume infinite bounds always.
    integrand::OperatorTerm
    variable::SymbolicUtils.Sym

    function UnevaluatedIntegral(integrand::Number, variable::SymbolicUtils.Sym{Number})
        # println("UE Constructed w $(typeof(integrand))")
        return integrand == 0 ? 0 : new(OperatorTerm(normalorder(integrand)), variable)
    end

    function UnevaluatedIntegral(integrand::Union{OperatorTerm,SymbolicUtils.Symbolic}, variable::SymbolicUtils.Sym{Number})
        # println("UE Constructed w $(typeof(integrand)): $(new(OperatorTerm(normalorder(integrand)), variable))")
        new(OperatorTerm(normalorder(integrand)), variable)
    end

    function UnevaluatedIntegral(integrand::T where {T <: OperatorSym}, variable::SymbolicUtils.Sym{Number})
        # println("UE Constructed w $(typeof(integrand))")
        new(OperatorTerm(normalorder(integrand)), variable)
    end

    function UnevaluatedIntegral(integrand::Ket, variable::SymbolicUtils.Sym{Number})
        # println("UE constructed w $(typeof(integrand))")
        Ket( new(OperatorTerm(integrand.op), variable) )
    end

    function UnevaluatedIntegral(integrand::Bra, variable::SymbolicUtils.Sym{Number})
        # println("UE constructed w $(typeof(integrand))")
        Bra( new(OperatorTerm(integrand.op), variable) )
    end

    function UnevaluatedIntegral(integrand::KetState, variable::SymbolicUtils.Sym{Number})
        # println("UE constructed w $(typeof(integrand))")
        dict = Dict{Ket,SymorNum}()
        for (k,v) in integrand.states
                dict[k] = get(dict, k, 0) + UnevaluatedIntegral(v * k.op, variable)
        end
        return KetState(dict)
    end
end
# :normal, :default, :bold, :black, :blink, :blue, :cyan, :green, :hidden, :light_black, :light_blue, :light_cyan, :light_green, :light_magenta, :light_red, :light_yellow, :magenta, :nothing, :red, :reverse, :underline, :white, or :yellow
function _KetState(int::UnevaluatedIntegral) 
    integrand = 0
    for (key, value) in int.integrand.terms
        integrand += value * key * vacuum()
    end
    # printstyled(integrand, "\n", color=:light_magenta)
    integrand == 0 && return 0
    return UnevaluatedIntegral(sum( v * k.op for (k,v) in integrand.states), int.variable)
end

function Base.show(io::IO, integral::UnevaluatedIntegral)
    print(io, "∫d$(integral.variable) ($(integral.integrand)) ")
end
# ipynb printing using latex
function Base.show(io::IO, ::MIME"text/latex", integral::UnevaluatedIntegral)
    print(io, "\\int \\mathrm{d}$(integral.variable) \\left($(integral.integrand)\\right)")
end


function integrate(ks::KetState)
    sum([ v * k.op isa UnevaluatedIntegral ? integrate(v * k.op) * vacuum() : error("not an UnevaluatedIntegral") for (k,v) in ks.states])
end
function integrate(ui::UnevaluatedIntegral)
    return integrate(ui.integrand, ui.variable)
end

function integrate(integrand::OperatorTerm, k::SymbolicUtils.Sym)
    no_int = normalorder(integrand)
    # println(no_int)
    integrated = 0
    for (term, coeff) in no_int.terms
        coeff = simplify(coeff)
        # Search for δ(p ± k) in coeff
        params = SymbolicUtils.Chain([r,r_c,r_lrc,rm,rm_c,rm_lrc])(coeff)
        # print comma separated coeff, params, Term
        # printstyled("Coeff: $coeff, Params: $params, Term: $term \n", color=:grey)

        if params !== coeff #i.e. a match has been found
            # printstyled("Found $params deps $k in $coeff \n", color=:green)
            k_replacement = Symbolics.solve_for(params ~ 0, k)
            # printstyled("Replacing $k with $k_replacement \n", color=:green)
            integrated_coeff = substitute(coeff, Dict(
                δ(params) => 1,
                k => k_replacement
            ))
            subbed_term = substitute(term, Dict(k => k_replacement))
            # printstyled("Final term is $subbed_term \n", color=:green)
            integrated += integrated_coeff * subbed_term
        else
            # printstyled("No match found in $coeff: Adding $(UnevaluatedIntegral(coeff * term, k))\n", color=:red)
            integrated += UnevaluatedIntegral(coeff * term, k)
        end
    end
    return integrated
end

function integrate(integrand::OperatorSym, k::SymbolicUtils.Sym)
    return integrate(OperatorTerm(integrand), k)
end

function integrate(integrand::Ket, k::SymbolicUtils.Sym)
    return Ket(integrate(integrand.op, k))
end

function integrate(integrand::KetState, k::SymbolicUtils.Sym)
    return sum([integrate(val * key.op, k) * vacuum() for (key,val) in integrand.states])
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
# Use occursin to filter out stuff that doesnt depend on the integration variable
+(a::UnevaluatedIntegral, b::SymorNum) = (b isa Number && b == 0) ? a : OperatorTerm(Dict{OperatorSym,SymorNum}(UnevaluatedIntegral(a.integrand, a.variable) => 1, b*one(Operator) => 1))
+(a::SymorNum, b::UnevaluatedIntegral) = (a isa Number && a == 0) ? b : OperatorTerm(Dict{OperatorSym,SymorNum}(UnevaluatedIntegral(b.integrand, b.variable) => 1, a*one(Operator) => 1))
+(a::UnevaluatedIntegral, b::OperatorSym) = OperatorTerm(Dict{OperatorSym,SymorNum}(UnevaluatedIntegral(a.integrand, a.variable) => 1, b => 1))
+(a::OperatorSym, b::UnevaluatedIntegral) = OperatorTerm(Dict{OperatorSym,SymorNum}(UnevaluatedIntegral(b.integrand, b.variable) => 1, a => 1))
+(a::UnevaluatedIntegral, b::OperatorTerm) = b + OperatorTerm(Dict{OperatorSym,SymorNum}(UnevaluatedIntegral(a.integrand, a.variable) => 1))
+(a::OperatorTerm, b::UnevaluatedIntegral) = a + OperatorTerm(Dict{OperatorSym,SymorNum}(UnevaluatedIntegral(b.integrand, b.variable) => 1))

-(a::UnevaluatedIntegral) = UnevaluatedIntegral(-a.integrand, a.variable)
-(a::UnevaluatedIntegral, b::UnevaluatedIntegral) = a + (-b)

# Make vanishing operator applications vanish
function *(a::UnevaluatedIntegral, b::Ket)
    # printstyled(a.integrand * b.op, "\n", color=:blue)
    return _KetState(UnevaluatedIntegral(a.integrand * b.op, a.variable))
end
# @which UnevaluatedIntegral(a_p * a_q',q) * v
# integrate(UnevaluatedIntegral(a_p * a_q',q) * v)


*(a::Bra, b::UnevaluatedIntegral) =Bra(UnevaluatedIntegral(a.op * b.integrand, b.variable))

*(a::UnevaluatedIntegral, b::SymorNum) = UnevaluatedIntegral(a.integrand * b, a.variable)
*(a::SymorNum, b::UnevaluatedIntegral) = UnevaluatedIntegral(a * b.integrand, b.variable)

*(a::UnevaluatedIntegral, b::OperatorSym) = UnevaluatedIntegral(a.integrand * b, a.variable)
*(a::OperatorSym, b::UnevaluatedIntegral) = UnevaluatedIntegral(a * b.integrand, b.variable)

function *(a::UnevaluatedIntegral, b::OperatorTerm)
    integrand = a.integrand * b
    # TODO
    UnevaluatedIntegral(a.integrand * b, a.variable)
end
*(a::OperatorTerm, b::UnevaluatedIntegral) = UnevaluatedIntegral(a * b.integrand, b.variable)




normalorder(a::UnevaluatedIntegral) = UnevaluatedIntegral(normalorder(a.integrand),a.variable)


# UnevaluatedIntegral(0,q)
# UnevaluatedIntegral(5,q)
# UnevaluatedIntegral(q,q)
# UnevaluatedIntegral(a_q,q)
# UnevaluatedIntegral(a_q^2,q)
# UnevaluatedIntegral(a_q * a_p',q)
# UnevaluatedIntegral(a_q * a_p' + a_p * a_q',q)

# UnevaluatedIntegral(5,q) * v
# UnevaluatedIntegral(q,q) * v
# UnevaluatedIntegral(a_q',q) * v
# UnevaluatedIntegral(a_q'^2,q) * v
# UnevaluatedIntegral(a_q * a_p',q) * v
# UnevaluatedIntegral(a_q * a_p' + a_p * a_q',q) * v

# UnevaluatedIntegral(5 * v,q)
# UnevaluatedIntegral(q * v,q)
# UnevaluatedIntegral(a_q' * v,q)
# UnevaluatedIntegral(a_q'^2 * v,q)
# UnevaluatedIntegral(a_q * a_p' * v,q)
# UnevaluatedIntegral(a_q * a_p' * v + a_p * a_q' * v,q)