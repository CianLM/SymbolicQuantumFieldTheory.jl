# ! FIX: This necessitates p be included
@syms p q
# is_integration_variable(x::typeof(p)) = p - x isa Number && p - x == 0
# is_integration_variable(x) = false
# @syms a b c d
# @syms x y z
# k_equals(k::typeof(p),x::SymbolicUtils.Symbolic) = Symbolics.solve_for(x ~ 0,k)
# r = @rule δ(~~x + ~y::is_integration_variable + ~~z) => +(~~x...,~y, ~~z...)
# r_c = @rule ~~b*δ(~~x + ~y::is_integration_variable + ~~z) => +(~~x...,~y, ~~z...)
# r_lrc = @rule ~~a + ~~b*δ(~~x + ~y::is_integration_variable + ~~z) + ~~c => +(~~x...,~y, ~~z...)

# rm = @rule δ(~~x + ~w*~y::is_integration_variable + ~~z) => +(~~x...,w*~y, ~~z...)
# rm_c = @rule ~~b*δ(~~x + ~w*~y::is_integration_variable + ~~z) => +(~~x...,w*~y, ~~z...)
# rm_lrc = @rule ~~a + ~~b*δ(~~x + ~w*~y::is_integration_variable + ~~z) + ~~c => +(~~x...,w*~y, ~~z...)

################
# r = @rule δ(~~x + ~y::is_integration_variable + ~~z) => k_equals(~y,+(~~x...,~y, ~~z...))
# r_c = @rule ~~b*δ(~~x + ~y::is_integration_variable + ~~z) => k_equals(~y,+(~~x...,~y, ~~z...))
# r_lrc = @rule ~~a + ~~b*δ(~~x + ~y::is_integration_variable + ~~z) + ~~c => k_equals(~y,+(~~x...,~y, ~~z...))

# rm = @rule δ(~~x + ~w*~y::is_integration_variable + ~~z) => k_equals(~y,+(~~x...,w*~y, ~~z...))
# rm_c = @rule ~~b*δ(~~x + ~w*~y::is_integration_variable + ~~z) => k_equals(~y,+(~~x...,w*~y, ~~z...))
# rm_lrc = @rule ~~a + ~~b*δ(~~x + ~w*~y::is_integration_variable + ~~z) + ~~c => k_equals(~y,+(~~x...,w*~y, ~~z...))
################
# ex = δ(p - q)
# ex_c = 2*α^2*p*δ(p - q)
# ex_lrc = 5 + 2*α^2*p*δ(p - q)  - α^2*p
# rex = δ(q - p)
# rex_c = 2*α^2*p*δ(q - p)
# rex_lrc = 5 + 2*α^2*p*δ(q - p) - α^2*p
# SymbolicUtils.Chain([r])(ex)
# SymbolicUtils.Chain([r_c])(ex_c)
# SymbolicUtils.Chain([r_lrc])(ex_lrc)
# SymbolicUtils.Chain([rm])(rex)
# SymbolicUtils.Chain([rm_c])(rex_c)
# SymbolicUtils.Chain([rm_lrc])(rex_lrc)