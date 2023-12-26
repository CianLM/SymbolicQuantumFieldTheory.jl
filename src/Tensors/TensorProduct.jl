struct TensorProduct
    tensors::Vector{Tensor}
    function TensorProduct(x::Union{Vector{Tensor},Vector{Tensor{F}}})  where F <: Field
        if isempty(x)
            return 1
        # elseif length(x) == 1 # we allow 1-products
        #     return x[1]
        # if the tensor product contains one(Operator) we can remove it
        elseif one(Tensor) in x && length(x) > 1
            new(filter(t -> t != one(Tensor), x))
        elseif index_legal(x)
            new(x)
        end
    end
    function TensorProduct(x::Tensor{F}...) where F <: Field
        return TensorProduct(collect(x))
    end
    # TensorProduct(x::) = new(Tensor[x...])
    Base.one(::Type{TensorProduct}) = TensorProduct(one(Tensor))
end
# one(Float64)
# one(Int64)
# one(TensorProduct)

"""
Iterate through the tensors in `x::Vector{Tensor}` and check that no index is repeated
 more than twice (and that they only appear in contra/covariant pairs).
"""
function index_legal(x::Union{Vector{Tensor{F}},Vector{Tensor}}) where F <: Field
    indices = Dict{Symbol,Int}()
    for tensor in x
        for index in tensor.indices
            if !haskey(indices, index.symbol)
                indices[index.symbol] = index.covariant
            else
                @assert indices[index.symbol] < 2 "Index $index appears more than twice."
                @assert index.covariant != indices[index.symbol] "Index $index appears twice in a $(Bool(indices[index.symbol]) ? "co" : "contra")variant position."
                indices[index.symbol] = 2
            end
        end
    end
    return true
end

begin "TermInterface"
    function istree(x::TensorProduct)
        #println("TensorProduct: istree called on $x")
        return true
    end

    function exprhead(x::TensorProduct)
        #println("TensorProduct: Exprhead called on $x")
        return :call
    end

    function operation(x::TensorProduct)
        #println("TensorProduct: Operation called on $x")
        return TensorProduct
    end

    function arguments(x::TensorProduct)
        #println("TensorProduct: Arguments called on $x")
        return x.tensors
    end

    function metadata(x::TensorProduct)
        #println("TensorProduct: Metadata called on $x")
        return nothing
    end

    function similarterm(t::TensorProduct, f, args, symtype; exprhead=:call, metadata=nothing)
        #println("TensorProduct: similar term called with $f, $args, $symtype, $metadata, $exprhead")
        return f(args...)
    end
end

function Base.show(io::IO, s::TensorProduct)
    print(io, join(s.tensors, " "))
end

@latexrecipe function f(x::TensorProduct)
    env --> :equation
    cdot --> false
    return Expr(:call, :*, x.tensors...)
end

function length(x::TensorProduct)
    return length(x.tensors)
end

function reverse(x::TensorProduct)
    return TensorProduct(reverse(x.tensors))
end

Base.iterate(x::TensorProduct) = iterate(x.tensors)
Base.iterate(x::TensorProduct, i::Int) = iterate(x.tensors, i::Int)
Base.firstindex(x::TensorProduct) = 1
Base.getindex(x::TensorProduct, i::Int) = x.tensors[i]
Base.getindex(x::TensorProduct, i::AbstractVector{Int}) = TensorProduct(x.tensors[i])
Base.setindex!(x::TensorProduct, v::Tensor{F}, i::Int) where F <: Field = x.tensors[i] = v
Base.lastindex(x::TensorProduct) = length(x.tensors)

function Base.:(==)(x::TensorProduct, y::TensorProduct)
    # if isnormalordered(x) && isnormalordered(y)
    return isequal(x.tensors, y.tensors)
    # else
    #     return isequal(normalorder(x), normalorder(y))
    # end
end

# # @syms p q
# # a_p = a(p)
# # a_q = a(q)
# # @syms k l
# # a_k = a(k)
# # a_l = a(l)
# # a_p * a_q


# # a_p * (a_q * a_k)
# # a_p * (a_q * a_q)
# # a_p * (a_q^2 * a_q)
# # a_p * (a_q^2 * a_k)

# end
# # (a_p * a_q) * (a_k * a_p)
# # (a_p * a_q^2) * (a_q * a_p)
# # (a_p * a_q^2) * (a_k * a_p)
# # (a_p * a_q) * (a_q^2 * a_p)
# # (a_p * a_k) * (a_q^2 * a_p)
# # (a_p * a_q^2) * (a_q^2 * a_k)

function Base.hash(a::TensorProduct, h::UInt=UInt(0))
    h = Base.hash(length(a), h)
    for x in a.tensors
        h = Base.hash(x, h)
    end
    return h
end


"""
The number of free and contracted indices in a tensor product.
This is a useful signature as it is invariant under relabeling of indices.
"""
function signature(x::TensorProduct)
    free = Set{Index}()
    contracted = 0
    for tensor in x.tensors
        for index in tensor.indices
            # if the index is in free
            if Index(index.symbol, !index.covariant) ∈ free
                # remove it from free
                # println("removing $index from $free")
                delete!(free,Index(index.symbol, !index.covariant))
                # increment contracted
                contracted += 1
            else
                # println("adding $index to $free")
                # add it to free
                push!(free, index)
            end
        end
    end
    # covariant = count(i -> i.covariant, free)
    return (free, contracted)
end
free_indices(x::TensorProduct) = signature(x)[1]
contracted_indices(x::TensorProduct) = setdiff(vcat(map(x -> x.indices, x.tensors)...), signature(x)[1])

# Rule: If a metric tensor is in a tensor product and has at least 1 contracted index, apply it and raise/lower.
# First we define a function to check if a tensor product contains a metric tensor with at least 1 contracted index.
function contract_metric(x::TensorProduct)
    free_indices = signature(x)[1]
    for (i,tensor) in enumerate(x.tensors)
        println("tensor: $tensor, $(tensor_field(tensor)), $(any(ind -> ind ∉ free_indices, tensor.indices)), $(length(tensor.indices) == 2 ? tensor.indices[1].symbol != tensor.indices[2].symbol : tensor.indices )")
        if tensor_field(tensor) == Metric && any(ind -> ind ∉ free_indices, tensor.indices) && (tensor.indices[1].symbol != tensor.indices[2].symbol)
            println("here")
            # get the index that is contracted
            contracted_index = tensor.indices[findfirst(ind -> ind ∉ free_indices, tensor.indices)]
            println("contracted index: $contracted_index")
            # tensor.indices has 2 indices in it. One is contracted_index, the other we get with
            other_index = tensor.indices[findfirst(ind -> ind != contracted_index, tensor.indices)]
            # pop the metric tensor from the tensor product
            new_product = deepcopy(x.tensors)
            metric = popat!(new_product,i)
            # raise or lower the index
            for (j,new_tensor) in enumerate(new_product), (k,index) in enumerate(new_tensor.indices)
                if index.symbol == contracted_index.symbol
                    new_product[j].indices[k] = Index(other_index.symbol, other_index.covariant)
                    break
                end
            end
            return TensorProduct(new_product)
        end
    end
    return x
end



B = @Tensor B_μ
typeof(B)
typeof(raise(B, @Index μ))

H = Tensor(:H, [Index(:μ, false), Index(:ν, true)])
typeof(H)
typeof(raise(H, @Index μ))



