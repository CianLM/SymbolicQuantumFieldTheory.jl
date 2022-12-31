vacuum() = Ket()
vacuum()
@kets ψ ϕ
# ᵅᵝᵡᵟᵋᵠᶿ
# using Distributions
# Dirac(1)

function *(a::Operator, b::Ket)
    if a == Operator(:I, ()) # I is the identity operator
        return b
    elseif !a.adjoint && b == vacuum()
        # a∣0⟩ = 0
        return 0
    elseif !a.adjoint
        # for i in b.indices 
        b_ops = prod([Operator(:a, (i,), true) for i in b.name])
        return normalorder(a * b_ops) * vacuum()
    elseif a.adjoint && b == vacuum()
        # aₚ^† ∣0⟩ = ∣p⟩
        return Ket(a.indices)
    else
        # aₚ^† ∣q⟩ = ∣p; q⟩
        return Ket((a.indices..., b.name...))
    end
end
v = vacuum()
a_p * vacuum()
p = a_p' * vacuum()
a_p * p
a_p' * p

function *(a::OperatorPower, b::Ket)
    # ! Can be optimized. Currently just iteratively multiplies n times
    if a == Operator(:I, ()) # I is the identity operator
        return b
    elseif !a.adjoint && b == vacuum()
        # a^n∣0⟩ = 0
        return 0
    elseif !a.adjoint
        # a_p^n * ∣p...⟩
        applied = b
        for _ in 1:a.power
            applied = a.operator * applied
        end
        return applied
    elseif a.adjoint && b == vacuum()
        # aₚ^† ∣0⟩ = ∣p;... n times; p⟩
        # Need N tuple
        return Ket(tuple([a.operator.indices[1] for _ in 1:a.power]...))

    else
        # aₚ^† ∣q⟩ = ∣p; q⟩
        return Ket(tuple([a.operator.indices[1] for _ in 1:a.power]..., b.name...))
    end
end

function *(a::OperatorProduct, b::Ket)
    if length(a) == 1
        return a[1] * b
    end
    if !a[end].adjoint && b == vacuum()
        # a∣0⟩ = 0
        return 0
    end
    if isnormalordered(a)
        applied = b
        for op in reverse(a)
            applied = op * applied
        end
        return applied
    else
        # Otherwise, we need to do some normal ordering
        return normalorder(a) * b
    end
end

function *(a::OperatorTerm, b::Ket)
    d = Dict{Ket,SymorNum}()
    println(a)
    for (ka, va) in a.terms
        applied = ka * b
        # print(typeof(ka), " ", typeof(b), " ", typeof(applied), " ")
        println("$ka * $b = $applied")
        if applied isa Ket
            # println("$applied is a Ket")
            d[applied] = get(d, applied, 0) + va
        elseif applied isa KetState
            # println("$applied is a KetState")
            for (kb, vb) in applied
                d[kb] = get(d, kb, 0) + va * vb
            end
        # else
        #     println("$applied is neither a Ket nor a KetState")
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

@syms α
@variables 𝛼
typeof(𝛼) <: SymorNum
r = @rule conj(conj(x)) => x
q = vacuum()' * (α * a_p * a_q)


# |p⟩ = a†ₚ |0⟩
# aₚ|p⟩ = |0⟩
normalorder(a_p * a_q' * a_k')

v = vacuum()
p1 = a_p' * v
p2 = a_q' * p1
p2 *= α
p3 = a_k * p2
p4 = a_l' * p3


va = a_k * a_p' * a_q' * v
vb = a_k * a_q' * (a_p' * v)
vc = a_k * (a_q' * a_p') * v
va == vb == vc
normalorder(a_k * a_l * a_p' * a_q') * va
2(a_k' * a_l') * va

# Ket((:q, :p)) + Ket((:p, :q))

a_p^2 * v
a_p'^2 * v
a_p'^2 * a_q' * v
a_p'^2 * (a_q' * v)
a_q^2 * (a_p'^3 * v)
a_q^2 * a_p'^3 * v

v' *  a_p^2 * a_q^2 * a_k'^2 
v' * (a_p^2 * a_q^2 * a_k'^2)
v' * (a_p^2 * a_q^2 * a_k'^2 * a_l'^2  * v)
v' * (a_p^2 * a_q^2 * a_k'^2 * a_l'^2) * v
v' * (a_p^2 * a_q^2 * a_k'^2 *(a_l'^2  * v))
normalorder(a_p * a_q^2 * a_k'^2 * a_l')


a_k^2 * (a_q'^2 * a_p'^2 * v)
(a_k^2 * a_q'^2 * a_p'^2) * v

normalorder(a_k * normalorder(a_k * a_q'^2 * a_p'^2)) * v
normalorder(a_k^2 * a_q'^2 * a_p'^2) * v


a = a_p' * a_q' * a_k' * a_l' * v
b = a_q' * a_p' * a_k' * a_l' * v
v
i =  a_p' * v
o =  a_q' * v
sc = o' * i
@syms p q Delta(x)
texpr = Delta(q - p) * 2π*p

substitute(texpr, Dict(
    Delta(q - p) => 1,
     p => -Symbolics.solve_for(
        arguments(Delta(q - p))[1] ~ 0, p
    )
))

# Define a rule that generalises the above. Namely,
# Find Delta(p - anything) and replace it with 1.
# Using slot variables (see https://symbolicutils.juliasymbolics.org/api/) to represent 'anything'
@syms x
r = @rule Delta(~x) --> ~x
rt = r(Delta(p - x))


@syms p q
is_integration_variable(x::typeof(p)) = p - x isa Number && p - x == 0
is_integration_variable(x) = false
@syms a b c d
@syms x y z
k_equals(k::typeof(p),x::SymbolicUtils.Symbolic) = Symbolics.solve_for(x ~ 0,k)
r = @rule Delta(~~x + ~y::is_integration_variable + ~~z) => +(~~x...,~y, ~~z...)
r_c = @rule ~~b*Delta(~~x + ~y::is_integration_variable + ~~z) => +(~~x...,~y, ~~z...)
r_lrc = @rule ~~a + ~~b*Delta(~~x + ~y::is_integration_variable + ~~z) + ~~c => +(~~x...,~y, ~~z...)

rm = @rule Delta(~~x + ~w*~y::is_integration_variable + ~~z) => +(~~x...,w*~y, ~~z...)
rm_c = @rule ~~b*Delta(~~x + ~w*~y::is_integration_variable + ~~z) => +(~~x...,w*~y, ~~z...)
rm_lrc = @rule ~~a + ~~b*Delta(~~x + ~w*~y::is_integration_variable + ~~z) + ~~c => +(~~x...,w*~y, ~~z...)

################
# r = @rule Delta(~~x + ~y::is_integration_variable + ~~z) => k_equals(~y,+(~~x...,~y, ~~z...))
# r_c = @rule ~~b*Delta(~~x + ~y::is_integration_variable + ~~z) => k_equals(~y,+(~~x...,~y, ~~z...))
# r_lrc = @rule ~~a + ~~b*Delta(~~x + ~y::is_integration_variable + ~~z) + ~~c => k_equals(~y,+(~~x...,~y, ~~z...))

# rm = @rule Delta(~~x + ~w*~y::is_integration_variable + ~~z) => k_equals(~y,+(~~x...,w*~y, ~~z...))
# rm_c = @rule ~~b*Delta(~~x + ~w*~y::is_integration_variable + ~~z) => k_equals(~y,+(~~x...,w*~y, ~~z...))
# rm_lrc = @rule ~~a + ~~b*Delta(~~x + ~w*~y::is_integration_variable + ~~z) + ~~c => k_equals(~y,+(~~x...,w*~y, ~~z...))
################
ex = Delta(p - q)
ex_c = 2*α^2*p*Delta(p - q)
ex_lrc = 5 + 2*α^2*p*Delta(p - q)  - α^2*p
rex = Delta(q - p)
rex_c = 2*α^2*p*Delta(q - p)
rex_lrc = 5 + 2*α^2*p*Delta(q - p) - α^2*p
SymbolicUtils.Chain([r])(ex)
SymbolicUtils.Chain([r_c])(ex_c)
SymbolicUtils.Chain([r_lrc])(ex_lrc)
SymbolicUtils.Chain([rm])(rex)
SymbolicUtils.Chain([rm_c])(rex_c)
SymbolicUtils.Chain([rm_lrc])(rex_lrc)
1


# using Symbolics, SymbolicNumericIntegration

# function integrate(f::Expr, x::Symbol)
#     # Define the DiracDelta function as a symbolic function.
#     dirac_delta(x) = x == 0 ? Inf : 0
    
#     # Use the property of the DiracDelta function that the integral
#     # of the DiracDelta function with respect to x is equal to 1.
#     # Thus, the integral of the product of a function and the
#     # DiracDelta function with respect to x is equal to the value
#     # of the function at 0.
#     return subs(f, x, 0) * dirac_delta(x)
# end


