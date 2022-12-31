# Structure
# By default
comm(a_p, a_q') # is defined to be 1
# If the user wants to define a custom commutation relation they do
@operator x_p x_q
@comm [x_p, x_q'] = anything #(can depend on p and q)
# The comm macro should then set the commutator for any x_* 
# The best way to do this is to define operator with
# struct Operator{T<:Field} <: OperatorSym
#     ...
# such that the commutator can be overloaded depending on the field type.
# This type dependent struct is called a parametric type.
# @comm [a_p, a_q'] = 1, [b_p, b_q'] = 1
# The user can define a custom field type by
# struct MyField <: Field
#     ...
# and then @comm will define the commutator for MyField.
#

# @scalarfield a
# => a(k) isa Operator
# @complexfield a b
# => a(k) isa Operator && b(k) isa Operator

# Free Vector Field
# @comm [A_μ(x), Π^ν(y)] = i δ_μ^ν * δ^3(x-y)
# @comm [a_μ(p), a_ν(q)'] = -2 * η_{μν} * E_p * (2π)^3 * δ^3(p-q)

# Dirac Field
# @comm {b^s(p), b^r(q)'} = -2 * E_p * (2π)^3 * δ^3(p-q) * δ^sr

# Suppose user wants to impose the dirac field commutation relation above.
# They first need to define the field with
# abstract type DiracField <: Field end
# Then they define the operators with
# @operator DiracField b^s_p b^r_q
# Then they define the commutation relation with
# @comm {b^s_p, b^r_q'} = -2 * E_p * (2π)^3 * δ^3(p-q) * δ^sr
# This should set the commutator for all b^s_p and b^r_q as well as the daggered versions
# The operators then are fully defined and can be used in the rest of the code.
# e.g.
# b^s_p * b^r_q' * b^r_q * b^s_p'  # => 1
# b^s_p * b^s_p                    # => 0
# b^s_p * b^r_q' + b^r_q' * b^s_p  # => -2 * E_p * (2π)^3 * δ^3(p-q) * δ^sr
