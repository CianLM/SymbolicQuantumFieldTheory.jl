struct TensorSum
    terms::Dict{TensorProduct,SymorNum}

    function TensorSum(terms::Dict{TensorProduct,SymorNum})
        # Filter out terms with zero coefficients
        # println("Initialization dict $terms")
        terms = Dict(k => v for (k, v) in terms if v isa Number ? v != 0 : true)
        # println("Filtered dict $terms")
        # If there are no terms left, return 0
        isempty(terms) && return 0
        # @show terms
        terms = simplify_tensor_dict(terms)
        tensors = keys(terms)
        signatures = signature.(tensors)
        # println(tensors)
        @assert all(s -> s[1] == signatures[1][1], signatures) "Free indices do not match: $(first(tensors)) and $([tensors...][findfirst(x -> free_indices(x) != free_indices(first(tensors)), [tensors...])])"
        return new(terms)
    end
    # TensorSum(a::TensorSum) = new(a.terms)
    TensorSum(a::TensorProduct) = new(Dict{TensorProduct,SymorNum}(a => 1))
    TensorSum(a::SymbolicUtils.Symbolic) = new(Dict{TensorProduct,SymorNum}(one(TensorProduct) => a))
    TensorSum(a::Number) = a == 0 ? 0 : new(Dict{TensorProduct,SymorNum}(one(TensorProduct) => a))
end
# !! for internal use only
# !! This works but could be more efficient and have a better type signature
function _TensorSum(x::Union{TensorProduct,SymorNum}...)
    # x is [k1, k2, ..., kn, v1, v2, ..., vn]
    # Assert x has even length
    @assert length(x) % 2 == 0
    # Construct the Dict
    # terms = Dict{TensorProduct,SymorNum}()
    # for i in 1:length(x) ÷ 2
    #     terms[x[i]] = x[i + length(x) ÷ 2]
    # end
    # More efficient construction:
    terms = Dict{TensorProduct,SymorNum}(x[1:length(x) ÷ 2] .=> x[length(x) ÷ 2 + 1:end])
    return TensorSum(terms)
end

# # Some methods overwritten later. Must be high in file.
# # Define + between {SymorNum, Tensor, TensorProduct} to use promote
# +(a::Union{SymorNum, Tensor{F}, TensorProduct, TensorSum}, b::Union{Tensor{G}, TensorProduct, TensorSum}) where {F <: Field, G <: Field} = +(promote(a, b)...)
# *(a::Union{SymorNum, Tensor{F}, TensorProduct, TensorSum}, b::Union{Tensor{G}, TensorProduct, TensorSum}) where {F <: Field, G <: Field} = *(promote(a, b)...)


length(x::TensorSum) = length(x.terms)


function Base.show(io::IO, s::TensorSum)
    print(io, replace(join([
            # If v is symbolic
            if v isa SymbolicUtils.Add || v isa SymbolicUtils.Div
                "(" * string(v) * ")" * string(k)
            elseif v isa SymbolicUtils.Symbolic
                string(v) * string(k)
                # If the coefficient is 1, then don't print it
            elseif v == 1
                string(k)
                # If the coefficient is -1, then print -k
            elseif v == -1
                "-" * string(k)
                # If the coefficient is purely imaginary, then print bim
            elseif v == im
                "im" * string(k)
                # If the coefficient is purely imaginary, then print -bim
            elseif v == -im
                "-im" * string(k)
            elseif real(v) == 0
                string(imag(v)) * "im" * string(k)
                # If the coefficient is complex, then print it as (a+bim)
            elseif typeof(v) <: Complex
                "(" * string(v) * ")" * string(k)
            else
                string(v) * string(k)
            end
            for (k, v) in s.terms
        ], " + "), "+ -" => "- ")
    )
end

TeXedTensor(tensor::Tensor) = string(tensor.symbol) * (length(tensor.indices) > 0 ? join(["{}$(index.covariant ? '_' : '^'){$(index)}" for index in tensor.indices],"") : "")
TeXedTensor(x::TensorProduct) = *(TeXedTensor.(x.tensors)...)
@latexrecipe function f(x::TensorSum)
    env --> :equation
    cdot --> false
    return Expr(:call, :*, 
            # k1, v1, k2, v2, ..., kn, vn
        replace(join([
        if v isa SymbolicUtils.Add || v isa SymbolicUtils.Div
            "(" * string(v) * ")" * TeXedTensor(k)
        elseif v isa SymbolicUtils.Symbolic
            string(v) * TeXedTensor(k) 
            # If the coefficient is 1, then don't print it
        elseif v == 1
            TeXedTensor(k)
            # If the coefficient is -1, then print -ket
        elseif v == -1
            "-" * TeXedTensor(k)
            # If the coefficient is purely imaginary, then print bim
        elseif v == im
            "i" * TeXedTensor(k)
            # If the coefficient is purely imaginary, then print -bim
        elseif v == -im
            "-i" * TeXedTensor(k)
        elseif real(v) == 0
            string(imag(v)) * "i" * TeXedTensor(k)
            # If the coefficient is complex, then print it as (a+bim)
        elseif typeof(v) <: Complex
            "(" * string(v) * ")" * TeXedTensor(k)
        else
            string(v) * TeXedTensor(k)
        end
        for (k, v) in x.terms], " + "), "+ -" => "- ")...

    )

end

Base.show(io::IO, ::MIME"text/latex", x::TensorProduct) = print(io, "\$\$ " * latexify(x) * " \$\$")
Base.show(io::IO, ::MIME"text/latex", x::TensorSum) = print(io, "\$\$ " * latexify(x) * " \$\$")
Base.show(io::IO, ::MIME"text/latex", x::Tensor) = print(io, "\$\$ " * latexify(x) * " \$\$")

begin "TermInterface"
    function istree(x::TensorSum)
        #println("TensorSum: $(x) istree called")
        return true
    end

    function exprhead(x::TensorSum)
        #println("TensorSum: $(x) exprhead called")
        return :call
    end

    function operation(x::TensorSum)
        #println("TensorSum: $(x) operation called")
        return _TensorSum
        # return +
    end

    function arguments(x::TensorSum)
        #println("TensorSum: $(x) arguments called")
        return [keys(x.terms)..., values(x.terms)...]
        # return keys(x.terms) .* values(x.terms)
    end

    function similarterm(t::TensorSum, f, args, symtype=symtype(t); metadata=nothing, exprhead=exprhead(t))
        #println("TensorSum: $(f(args...)) similar term called with $f, $args, $symtype, $metadata, $exprhead")
        # ? Can be refactored such that the logic in _TensorSum is implemented here.
        return f(args...)
    end
end

begin "Equalities"
    function Base.:(==)(x::TensorSum, y::TensorSum)
        return isequal(normalorder(x).terms, normalorder(y).terms)
    end

    function Base.:(==)(x::TensorSum, y::TensorProduct)
        return isequal(normalorder(x).terms, Dict(y => 1))
    end

    function Base.:(==)(x::TensorProduct, y::TensorSum)
        return isequal(normalorder(y).terms, Dict(x => 1))
    end

    function Base.:(==)(x::TensorSum, y::SymorNum)
        return isequal(normalorder(x).terms, Dict(one(TensorProduct) => y))
    end

    function Base.:(==)(x::SymorNum, y::TensorSum)
        return isequal(normalorder(y).terms, Dict(one(TensorProduct) => x))
    end
end

Base.getindex(x::TensorSum, i::Int) = x.terms[i]
Base.setindex!(x::TensorSum, v::SymorNum, i::TensorProduct) = x.terms[i] = v

function Base.convert(::Type{TensorSum}, x::TensorProduct)
    return TensorSum(Dict{TensorProduct,SymorNum}(x => 1))
end

function Base.convert(::Type{TensorSum}, x::Tensor{F}) where F <: Field
    return TensorSum(Dict{TensorProduct,SymorNum}(TensorProduct(x) => 1))
end

function Base.convert(::Type{TensorSum}, x::SymorNum)
    return TensorSum(Dict{TensorProduct,SymorNum}(one(TensorProduct) => x))
end

function Base.convert(::Type{TensorProduct}, x::Tensor{F}) where F <: Field
    return TensorProduct(x)
end

# Define promote_rule for SymorNum, Tensor, and TensorProduct
Base.promote_rule(::Type{TensorSum}, ::Type{<:Number}) = TensorSum
Base.promote_rule(::Type{TensorSum}, ::Type{<:SymbolicUtils.Symbolic}) = TensorSum
Base.promote_rule(::Type{TensorSum}, ::Type{Tensor{F}}) where F <: Field = TensorSum
Base.promote_rule(::Type{TensorSum}, ::Type{TensorProduct}) = TensorSum

Base.promote_rule(::Type{TensorProduct}, ::Type{<:Number}) = TensorSum
Base.promote_rule(::Type{TensorProduct}, ::Type{<:SymbolicUtils.Symbolic}) = TensorSum
Base.promote_rule(::Type{TensorProduct}, ::Type{Tensor{F}}) where F <: Field = TensorProduct

Base.promote_rule(::Type{Tensor{F}}, ::Type{<:Number}) where F <: Field = TensorSum
Base.promote_rule(::Type{Tensor{F}}, ::Type{<:SymbolicUtils.Symbolic}) where F <: Field = TensorSum


# Base.promote_rule(::Type{TensorProduct}, ::Type{TensorProduct}) = TensorProduct
# Base.promote_rule(::Type{Tensor{F}}, ::Type{Tensor{G}}) where {F <: Field, G <: Field} = Tensor
# @field MyField
# promote_type(Tensor{MyField}, Tensor{MyField})
# promote_type(TensorProduct, TensorProduct)
# typeof(promote(b,b)[1])



function +(a::TensorSum, b::TensorSum)
    # type = Union{typeof(values(a.states)...), typeof(values(b.states)...)}
    d = Dict{TensorProduct,SymorNum}()
    for k in keys(a.terms) ∪ keys(b.terms)
        # println("key: $k")
        # println("$(get(a.terms, k, 0)) + $(get(b.terms, k, 0)) = $(get(a.terms, k, 0) + get(b.terms, k, 0))")
        v = get(a.terms, k, 0) + get(b.terms, k, 0)
        d[k] = v
    end
    return TensorSum(d)
end

-(a::TensorSum, b::TensorSum) = a + (-b)
-(a::TensorSum) = TensorSum(Dict{TensorProduct,SymorNum}(k => -v for (k, v) in a.terms))
-(a::Union{Tensor, TensorProduct}) = -convert(TensorSum, a)


TensorObject = Union{Tensor, TensorProduct, TensorSum}
begin "Addition"
    +(a::SymorNum, b::TensorObject) = convert(TensorSum,a) + convert(TensorSum,b)
    +(a::TensorObject, b::SymorNum) = convert(TensorSum,a) + convert(TensorSum,b)
    #
    +(a::Tensor, b::Union{TensorProduct,TensorSum}) = +(promote(a,b)...)
    +(a::TensorProduct, b::Union{Tensor, TensorSum}) = +(promote(a,b)...)
    +(a::TensorSum, b::Union{Tensor, TensorProduct}) = +(promote(a,b)...)
    # Promote on 2 of the same type always returns the same type, so we must define these two explicitly
    +(a::Tensor{F}, b::Tensor{G}) where {F <: Field, G <: Field} = convert(TensorSum, a) + convert(TensorSum, b)
    +(a::TensorProduct, b::TensorProduct) = convert(TensorSum,a) + convert(TensorSum,b)
    # 
    +(a::TensorSum, b::SymorNum) = (b isa Number && b == 0) ? a : a + TensorSum(Dict{TensorProduct,SymorNum}(one(TensorProduct) => b))
    +(a::SymorNum, b::TensorSum) = b + a
end

begin "Subtraction"
    -(a::SymorNum, b::TensorObject) = convert(TensorSum,a) - convert(TensorSum,b)
    -(a::TensorObject, b::SymorNum) = convert(TensorSum,a) - convert(TensorSum,b)

    -(a::Tensor, b::Union{TensorProduct,TensorSum}) = -(promote(a,b)...)
    -(a::TensorProduct, b::Union{Tensor, TensorSum}) = -(promote(a,b)...)
    -(a::TensorSum, b::Union{Tensor, TensorProduct}) = -(promote(a,b)...)
    # Promote on 2 of the same type always returns the same type, so we must define these two explicitly
    -(a::Tensor{F}, b::Tensor{G}) where {F <: Field, G <: Field} = convert(TensorSum, a) - convert(TensorSum, b)
    -(a::TensorProduct, b::TensorProduct) = convert(TensorSum,a) - convert(TensorSum,b)
    # 
    -(a::TensorSum, b::SymorNum) = (b isa Number && b == 0) ? a : a + TensorSum(Dict{TensorProduct,SymorNum}(one(TensorProduct) => -b))
    -(a::SymorNum, b::TensorSum) = -b + a
end



/(a::TensorSum, b::SymorNum) = TensorSum(Dict{TensorProduct,SymorNum}(k => v // b for (k, v) in a.terms))

# @which g() + g()

# +(a::TensorSum, b::TensorProduct) = a + TensorSum(Dict{TensorProduct,SymorNum}(b => 1))
# +(a::TensorProduct, b::TensorSum) = b + a

# -(a::SymorNum, b::TensorSum) = a + (-b)
# -(a::TensorSum, b::TensorProduct) = a + (-b)
# -(a::TensorProduct, b::TensorSum) = a + (-b)
# -(a::TensorSum, b::TensorSum) = a + (-b)
*(a::TensorSum, b::SymorNum) = TensorSum(Dict{TensorProduct,SymorNum}(k => v * b for (k, v) in a.terms))
*(a::SymorNum, b::TensorSum) = b * a

*(a::Union{Tensor, TensorProduct}, b::SymorNum) = convert(TensorSum, a) * b
*(a::SymorNum, b::Union{Tensor, TensorProduct}) = a * convert(TensorSum, b) 

*(a::TensorSum, b::Union{Tensor,TensorProduct}) = TensorSum(Dict{TensorProduct,SymorNum}((k * b) => v for (k, v) in a.terms))
*(a::Union{Tensor,TensorProduct}, b::TensorSum) = TensorSum(Dict{TensorProduct,SymorNum}((a * k) => v for (k, v) in b.terms))

# Products of TensorSums
function *(a::TensorSum, b::TensorSum)
    d = Dict{TensorProduct,SymorNum}()
    for (k1, v1) in a.terms
        for (k2, v2) in b.terms
            # println("$(k1) * $(k2) = $(k1 * k2)")
            # println("$(v1) * $(v2) = $(v1 * v2)")
            d[k1*k2] = get(d, k1 * k2, 0) + v1 * v2
        end
    end
    if isempty(d)
        return 0
    else
        return TensorSum(d)
    end
end

# -(a::Tensor{F}) where F <: Field = -convert(TensorSum, a)
# -(a::TensorProduct) = -convert(TensorSum, a)
# -(a::Tensor{F}, b::Tensor{G}) where {F <: Field, G <: Field} = convert(TensorSum, a) - convert(TensorSum, b)
# -(a::TensorProduct, b::TensorProduct) = convert(TensorSum,a) - convert(TensorSum,b)

*(x::Tensor{F}, y::Tensor{G}) where {F <: Field, G <: Field} = TensorProduct([x, y])
*(x::TensorProduct, y::TensorProduct) = TensorProduct([x.tensors..., y.tensors...])

*(x::TensorProduct, y::Tensor{F}) where F <: Field = TensorProduct([x.tensors..., y])
# This is fancy but very inefficient
# *(x::Tensor{F}, y::TensorProduct) where F <: Field = reverse(reverse(y) * x)
*(x::Tensor{F}, y::TensorProduct) where F <: Field = TensorProduct([x, y.tensors...])

function Base.hash(a::TensorSum, h::UInt=UInt(0))
    h = Base.hash(length(a), h)
    for (x, y) in a.terms
        h = Base.hash(x, h)
        h = Base.hash(y, h)
    end
    return h
end

# begin "Testing"
#     @Tensor A^🐉♥
#     B
#     c
#     b = raise(b,@Index μ)
#     a
#     promote(b * B, c)
#     b * B + c * lowerAll(c)
#     c * lowerAll(c)
#     # promote(b, b * B)[2].terms
#     2b * B + b * B
#     d = lower(lower(c, @Index ϕ), @Index χ)
#     2c * d * (1 + b * B) - 3


#     d
#     e = @Tensor C_αβ

#     y = g() + ∂() * ∂(ν)
#     # promote(c, c * B)
#     convert(TensorSum, b * B)
#     convert(TensorSum, 2).terms[one(TensorProduct)]
#     convert(TensorSum, b)
#     SymorNum
#     promote_type(Tensor, SymorNum)
#     promote_type(TensorSum, SymbolicUtils.Symbolic)
#     promote_type(TensorSum, Number)
#     promote(b, 2)
#     2 + b
#     B + B

#     b + 2
#     typeof(one(TensorProduct))
# end

function simplify_tensor_dict(x::Dict)
    seen_signatures = Dict{Tuple{Set{Index}, Int64}, Vector{Union{Tensor,TensorProduct}}}()
    new_tensor_dict = Dict{TensorProduct,SymorNum}()
    for (k,v) in x
        # println(k, signature(k))
        sig = signature(k)
        if haskey(seen_signatures, sig)
            found = false
            for tensor in seen_signatures[sig]
                if equal_up_to_relabelling(tensor, k)
                    # println("$k same as $tensor")
                    new_tensor_dict[tensor] += v
                    found = true
                    break
                end
            end
            # println("New term: $k")
            if !found
                new_tensor_dict[k] = v
            end
            push!(seen_signatures[sig], k)
        else
            new_tensor_dict[k] = v
            seen_signatures[sig] = [k]
        end
    end
    return new_tensor_dict
end
# u = d * raiseAll(d) + e * raiseAll(e)

function equal_up_to_relabelling(x::Tensor, y::Tensor)
    if x.symbol != y.symbol 
        return false
    end
    # No symmetry assumed. Must be identical up to index relabelling
    contracted_indices = contracted_indices(y)
    new_y_indices = copy(y.indices)
    for (i, index) in enumerate(new_y_indices)
        if index ∈ contracted_indices
            new_y_indices = x.indices[i]
        end
    end
    return x == Tensor(y.symbol, new_y_indices, y.metadata)
end

function equal_up_to_relabelling(x::TensorProduct, y::TensorProduct)
    # No symmetry assumed.
    # O(n) time complexity
    # println(map(x -> x.symbol, x.tensors), " ", map(x -> x.symbol, y.tensors), map(x -> x.symbol, x.tensors) == map(x -> x.symbol, y.tensors))
    if map(x -> x.symbol, x.tensors) != map(x -> x.symbol, y.tensors)
        return false
    end
    xDict = Dict{Index,Int64}()
    yDict = Dict{Index,Int64}()
    xindices = vcat(map(x -> x.indices, x.tensors)...)
    yindices = vcat(map(y -> y.indices, y.tensors)...)
    xindices = map(i -> Index(i.symbol, true, dim=i.dim), xindices)
    yindices = map(i -> Index(i.symbol, true, dim=i.dim), yindices)

    if length(xindices) != length(yindices)
        return false
    end
    for (i,xv) in enumerate(xindices)
        # println(join([i, get(xDict, xv, 0), get(yDict, yindices[i], 0)], " "))
        if get(xDict, xv, 0) != get(yDict, yindices[i], 0)
            return false
        end
        xDict[xv] = i
        yDict[yindices[i]] = i
    end
    # println("$x and $y are same")
    return true
end

equal_up_to_relabelling(x::Tensor, y::TensorProduct) = false
equal_up_to_relabelling(x::TensorProduct, y::Tensor) = false


# Experiments
# abstract type RecordType end
# macro CreateRecordType(name, field1, field2)
#     return quote
#         struct $name <: RecordType
#             # make each element of fields a field of the struct
#             # make the type the type of the variable in calling scope
#             $(Symbol(field1))::typeof($(Symbol(field1)))
#             $(Symbol(field2))::typeof($(Symbol(field1)))
#         end
#     end
# end
# name = "john"
# age = 1
# @CreateRecordType bruh3 name age
# Base.fieldnames(bruh3)
# bruh3(name, age)