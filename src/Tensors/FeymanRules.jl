# Steps to Feynman Rules
#// 1. Define fields and derivatives
#// 2. Define metric tensor and tensor products
#?  3. Define commutators and unique normal ordering
#//  4. Define sums of tensor products
#!  5. Parse vertex factor from interaction term

∂u(μ=@Index μ) = raise(∂(μ),μ)
@field ClassicalField
@field RealScalarField
# @DefineTensor RealScalarField φ
@DefineTensor ClassicalField P
@Indices μ ν ρ τ σ α β
φ = @Tensor φ
ℒ = φ * (∂u() * (@Tensor P_μν) + (@Tensor P_μν) * ∂u() ) * ∂u(ν) * φ
🎹 = φ * ∂() * ∂u() * φ
🚈 = φ * (@Tensor P_μν) * ∂u() * φ

function parseDerivatives(x::TensorProduct)
    # Traverse backwards through x.tensors adding tensors to a dict if they are derivatives with the key being the tensor they act on
    buckets = Dict{Tensor, Vector{Tensor}}()
    # e.g. ∂_μ ∂^μ A_💜 A^💜
    # should become
    # Dict{A_💜 => [∂_μ, ∂^μ], A^💜 => []}
    # keep track of the current non-derivative tensor
    current_tensor = x.tensors[end]
    for tensor in reverse(x.tensors)
        if tensor_field(tensor) == Derivative
            # if the current tensor is a derivative, add it to the bucket of the current tensor
            if haskey(buckets, current_tensor)
                push!(buckets[current_tensor], tensor)
            else
                buckets[current_tensor] = [tensor]
            end
        else
            # if the current tensor is not a derivative, it is the new current tensor
            current_tensor = tensor
        end
    end
    return buckets
end
parseDerivatives(🎹)
parseDerivatives(🚈)
parseDerivatives(ℒ)



