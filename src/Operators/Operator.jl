abstract type OperatorSym end
# *** Make I a subtype of OperatorSym
I = Operator(:I, ())

+(a::T where {T<:OperatorSym}, b::SymorNum) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, I => b))
+(a::SymorNum, b::T where {T<:OperatorSym}) = OperatorTerm(Dict{OperatorSym,SymorNum}(I => a, b => 1))
+(a::T where {T<:OperatorSym}, b::T where {T<:OperatorSym}) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, b => 1))

-(a::T where {T<:OperatorSym}) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => -1))
-(a::T where {T<:OperatorSym}, b::SymorNum) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, I => -b))
-(a::SymorNum, b::T where {T<:OperatorSym}) = OperatorTerm(Dict{OperatorSym,SymorNum}(I => a, b => -1))
-(a::T where {T<:OperatorSym}, b::T where {T<:OperatorSym}) = a == b ? 0 : OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1, b => -1))

*(a::T where {T<:OperatorSym}, b::SymorNum) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => b))
*(a::SymorNum, b::T where {T<:OperatorSym}) = OperatorTerm(Dict{OperatorSym,SymorNum}(b => a))
/(a::T where {T<:OperatorSym}, b::SymorNum) = OperatorTerm(Dict{OperatorSym,SymorNum}(a => 1 / b))
# * remains to be defined for T * T where T <: OperatorSym. Will be done in each file up the chain

# struct Operator <: OperatorSym
#     name::Symbol
#     indices::Tuple{Vararg{Symbol}}
#     adjoint::Bool

# Make Operator take a Field type
struct Operator{T<:Field} <: OperatorSym
    name::Symbol
    indices::Tuple{Vararg{Symbol}}
    adjoint::Bool

    function Operator{T}(name::Symbol, indices::Tuple{Vararg{Symbol}}, adjoint::Bool=false)
        # return new(name, indices, adjoint)
        return new{T}(name, indices, adjoint)
    end

    # function Operator(name::String)
    #     return new(Symbol(name))
    # end

    function Base.one(::Type{Operator})
        return Operator(:I, ())
    end

    function Base.show(io::IO, s::Operator)
        if s == one(Operator)
            print(io, "I")
        else
            print(io, s.name)
            if length(s.indices) > 0
                print(io, "_")
                print(io, join(s.indices, ""))
            end
            if s.adjoint
                print(io, "^†")
            end
        end
        # print(io, "$(s.name)_$(s.indices...)$("^†" ^ Int(s.adjoint))")
    end

    function istree(x::Operator)
        return false
    end

    function exprhead(x::Operator)
        return :call
    end

    # symtype
    function similarterm(t::Operator, f, args, symtype=Operator, metadata=nothing, exprhead=exprhead(t))
        return f(args...)
        # return SymbolicUtils.Term{symtype}(f, args, metadata, exprhead)
    end


end

# Define a string macro op"a_p" for Operator(:a,(:p))
    macro op_str(str)
    # Split the string into the name and indices
    name, indices = split(str, "_")
    # Convert the indices to a tuple of symbols
    indices = Symbol.(split(indices, ""))
    # Return the Operator
    return Operator(Symbol(name), tuple(indices...))
end

ishermitian(x) = (x.name == Operator(:I, ()).name)

function Base.:(==)(x::Operator, y::Operator)
    return isequal(x.name, y.name) && isequal(x.indices, y.indices) && (ishermitian(x) || isequal(x.adjoint, y.adjoint))
end

^(a::Operator, b::Number) = OperatorPower(a, b)

function Base.hash(x::Operator, h::UInt=UInt(0))
    h = Base.hash(string(x.name), h)
    h = Base.hash(string(x.indices), h)
    h = Base.hash(x.adjoint, h)
    return h
end

macro operator(names...)
    defs = map(names) do name
        # Check each name is of the form a_p
        if length(string(name)) < 3 || string(name)[2] != '_'
            error("Operator name must be of the form a_p (multiple indices allowed i.e. a_pq)")
        end

        # Split the name into the operator name and the index
        opname, indices = split(string(name), "_")
        indices = Tuple(Symbol.(split(indices, "")))
        :($(esc(name)) = Operator($(Expr(:quote, Symbol(opname))), $(Expr(:quote, indices))))
    end
    return Expr(:block, defs...,
        :(tuple($(map(x -> esc(x), names)...))))
end

@operator a_q a_p

adjoint(a::Operator) = Operator(a.name, a.indices, !a.adjoint)



#! ### TESTING ###
# @operator aₚ aₖ aₐ aₑ aₕ aᵢ aⱼ aₖ aₗ aₘ aₙ aₒ aₚ aᵣ aₛ aₜ aᵤ aᵥ aₓ
# # All possible alphabetical subscripts:
# # ₐ ᵦ ᵪ ₑ ᵧ ₕ ᵢ ⱼ ₖ ₗ ₘ ₙ ₒ ₚ ᵩ ᵣ ᵨ ₛ ₔ ₜ ᵤ ᵥ ₓ
# @operator a_p a_q a_k
# @syms x y

# Good syntax for defining the commutation relation for a scalar field is
# @scalarfield a
# @comm [a,a'] = i
macro scalarfield(a)
    return quote
        # @operator $a
        # @operator $a_p
        @comm [$a, ($a)'] = i
    end
end
@scalarfield b


macro comm(expr)
    # Check that expr is of the form [a,b] = c
    if expr.head != :(=) || expr.args[1].head == :vector || length(expr.args[1].args) != 2
        error("Invalid commutation relation: $expr")
    end
    # break expr into lhs and rhs
    lhs = expr.args[1] # [a,b]
    rhs = expr.args[2] # c
    # get a and b from lhs
    a = lhs.args[1]
    b = lhs.args[2]
    return println("[$a,$b] = $rhs")
    # comm should set the commutator of a and b to rhs
end

@operator a_p b_p
@syms i::Int64 f::Float64
c = comm(a_p, b_p', 1)
c(a * b)

@comm [1, :a] = 3

@comm [1, 2] = 3
@acomm {a, b} = 3





typeof(x * y)
q = SymbolicUtils.Mul(Number, 2, OrderedDict(x => 1, y => 1))
w = SymbolicUtils.Mul(Number, 2, Dict(y => 1, x => 1))

# SymbolicUtils.jl does not have non-commuting symbolic types implemented.
# We can use the following workaround:
#
# 1. Define a new type for non-commuting symbolic types i.e. Operators
# 2. Define a new type for multiplication of operators i.e. OperatorProduct which preserves order
#// 3. This OperatorProduct (replacing Mul) should then interface with Add and Pow from SymbolicUtils.jl
# Note: Add requires keys be subtypes of Number, so we can't use OperatorProduct as a key in Add
# Thus, 3. becomes Define OperatorAdd and OperatorPow to interface with OperatorProduct
# I am defining the BraKet Algebra. 
@syms c d
SymbolicUtils.Add(Number, 2, Dict(c => 1, d => 1))

# The Plan:
# Given a commutation relation:
# [a_p, a_q'] = i δ_pq
# we can define a rule that recursively simplifies an expression like:
# ⟨q|a_p a_q' |p⟩ = ⟨q|(a_q'a_p + i δ_pq)|p⟩ = ⟨q|a_q'a_p|p⟩ + i⟨q|δ_pq|p⟩ = ⟨0|0⟩+ i ⟨p|p⟩ = 1 + i
#                       ^^^ 
#                       a_q' annihilates the state q
