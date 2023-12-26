# Given an arbitrary product of tensors like
# ∂_μ ∂_ν ∂_ρ ∂_σ ∂^μ A_💜 A^💜 g^τ⎔ ∂_τ
# this is equivalent to
# [permuation of these ∂s] A_anything A^anything ∂_τ and the g^τ⎔ can go anywhere.
# we can use the following rules to impose a unique ordering of such equivalent tensors:
# 1. Move all metric tensors to the left and order them by decreasing number of free indices.
# 2. Order derivatives acting on a given tensor similarly.
# 3. Commuting tensors should be ordered by their symbol then indices.

@Indices μ ν ρ τ ϕ
a1 = @Tensor A^μρτ
a2 = @Tensor A_μρ^ϕ
a1 * a2
is_free_index(a1 * a2,raise(ϕ))
signature(a1 * a2)

function canonicalize(x::TensorProduct)
    free_indices, contracted_pairs = signature(x)
    # 1. Move all metric tensors to the left and order them by decreasing number of free indices.
    new_tensors = sort(x.tensors, by = t -> (tensor_field(t) == Metric) ? -count(i -> i in free_indices, t.indices) : 1)
    # println("new_tensors: $new_tensors")
    # 2. Order derivatives acting on a given tensor similarly.
    # 2.a. split the tensors into groups of tensors that act on the same tensor
    # splits = [Tensor[] for i in 1:length(x)]
    # i = 1
    # for tensor in new_tensors
    #     println("i=$i, Added $tensor to $(splits[i])")
    #     push!(splits[i], tensor)
    #     if tensor_field(tensor) != Derivative
    #         i += 1
    #         println("$tensor is not a derivative so incremented i to $i")
    #     end
    # end
    # println("splits: $splits")
    # # 2.b. sort each group of derivatives by decreasing number of free indices
    # for (i,split) in enumerate(splits)
    #     if length(splits) != 1
    #         println(splits[i])
    #         split[1:(end-1)] = sort(split[1:(end-1)], by = t -> -count(ind -> ind in free_indices, t.indices))
    #         println("after: $(splits[i])")
    #     end
    # end
    # 2.c. flatten the splits
    # new_tensors = prod([prod(split) for split in splits])
    return TensorProduct(new_tensors)
end


# a1 * a2 * g()
# find which method is called here with
@which (a1 * a2 )* g()

g() * raise(∂(),μ) * g([ρ,τ]) * (@Tensor A_💜)

@Indices 💜 💚 💛 💙 🐉 🐲
canonicalize(a1 * g())
canonicalize(a1 * a2 * g([💛, 💙]) * g([raise(💛), raise(💙)]) * g([raise(💜), raise(💚)]) * g([🐉, 💜]) )

canonicalize(∂() * ∂(ν) * ∂(raise(ν)) * ∂(ρ) * g([raise(ρ), raise(τ)]))