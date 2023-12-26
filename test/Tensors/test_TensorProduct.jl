# Bd * Bu
# # signature(Bu * Bd)
# # 🙎👱💁🙍
# ∂(@Index 💁) * Bd
# # rule to replace ∂(💁) with -i * k_💁
# r = @rule ~x::(x-> x == ∂(@Index 💁)) => -im
# r(∂(@Index 💁))
# # B = relabel(:f,:g,a) * relabel(:🐲,:μ,a)
# signature( (@Tensor B_μ) * (@Tensor A^μ) )


# tensor_field(g()) == Metric
# pg = raise(∂(),@Index μ)
# pg2 = contract_metric(pg * g()) * pg # ∂_ν ∂^μ
# pg3 = pg2 * raise(g(), @Index ν) # ∂_ν ∂^μ g^μ_ν
# signature(pg3)
# contract_metric(pg3) # ∂_ν ∂^ν
# gs = g([Index(:ρ,false), Index(:ρ,true)])
# tensor_field(raise(g(), @Index ν))