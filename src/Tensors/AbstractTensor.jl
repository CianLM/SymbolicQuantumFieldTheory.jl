abstract type Field end
abstract type Metric <: Field end
abstract type Derivative <: Field end
abstract type ComplexScalarField <: Field end # for spinors
abstract type RealVectorField <: Field end # for photons


struct AbstractTensor{F <: Field}
    name::Symbol

    function AbstractTensor{F}(name::Symbol) where F <: Field
        return new{F}(name)
    end
    AbstractTensor(name::Symbol) = AbstractTensor{Field}(name)
end

tensor_field(A::AbstractTensor{F}) where F <: Field = F

function Base.show(io::IO, s::AbstractTensor)
    print(io, s.name)
end

begin "TermInterface"
    function istree(x::AbstractTensor)
        # println("AT is not a tree")
        return false
    end

    function similarterm(t::AbstractTensor, f, args, symtype=Operator, metadata=nothing, exprhead=exprhead(t))
        # println("AO similar term called with $f, $args, $symtype, $metadata, $exprhead")
        return f(args...)
    end
end

macro field(name)
    return quote
        abstract type $name <: Field end
    end
end

# Macro that takes in a field and symbol and makes the symbol an AbstractTensor of that field.
macro DefineTensor(field, op)
    return :($(esc(op)) = AbstractTensor{$(esc(field))}($(Expr(:quote, Symbol(string(op))))))
end

@DefineTensor RealVectorField A

# # macro that checks if a variable is defined
macro check_field(op)
    return :($(Expr(:isdefined, esc(op))) && $(esc(op)) isa AbstractTensor ? tensor_field($(esc(op))) : Field)
end


# @macroexpand @check_field A
# @macroexpand @check_field $B
# Tensor{@check_field A}
# Tensor{@check_field D}
# 1
# f(A::Symbol) = @check_field A
# f(:B)

# Access value attached to a symbol inside a macro with
# eval(esc(:A))
# or, as eval inside a macro is bad practice, use
# @eval $(esc(:A))

macro get_value(var)
    return :($(var))
end
x = 1
@get_value x
z = 2

macro get_symbol(var)
    return :($(Expr(:quote, Symbol(string(var)))), $var)
end
@macroexpand @get_symbol x

1

# macro comm(ex)
#     MacroTools.@capture(ex, [a_, b_] = c_) || error("expected a commutation relation of the form [a(p), b(q)] = f(p,q)")
#     # println("[$(esc(a)),$(esc(b))] = $c")
#     # println(@__MODULE__)
#     # println(__module__)
#     return quote
#         # println(typeof($(esc(a))),typeof($(esc(b))))
#         function $(esc(:comm))($(esc(:u1))::Operator{field($(esc(a)))}, $(esc(:u2))::Operator{field($(esc(b)))})
#             esc_a = $(esc(a))
#             esc_b = $(esc(b))
#             # println("$esc_a, $esc_b")
#             # println("comm called with [$u1, $u2]")
#             if esc_a == one(Operator{field(esc_a)}) || esc_b == one(Operator{field(esc_b)})
#                 return 0
#             elseif !((esc_a.name == u1.name || esc_b.name == u2.name) || (esc_a.name == u2.name || esc_b.name == u1.name))
#                 return 0
#             elseif u1.adjoint == esc_a.adjoint && u2.adjoint == esc_b.adjoint || u1.adjoint == esc_b.adjoint && u2.adjoint == esc_a.adjoint
#                 cc = substitute($(esc(c)), Dict(zip(esc_a.indices, u1.indices)) ∪ Dict(zip(esc_b.indices, u2.indices)))
#                 # Parity fixing ± the specified commutation due to antisymmetry of the Lie bracket
#                 return (-1)^(Int(u1.adjoint == esc_b.adjoint) + Int(u1.name == esc_b.name)) * cc
#             else
#                 return 0
#             end
#         end
#     end
# end

# # @field TestField
# # @operators TestField ee ll
# # @syms p q g h
# # # @comm [b(p,g), c(q,h)'] = 2 * E(p) * twopi^3 * δ(p - q) * (g == h)
# # # comm(b(p,t), c(q,p)')
# # @comm [ee(q), ll(p)'] = 5
# # comm(ee(q), ll(p)')