a_p = a(p)
a_q = a(q)

ap_prod = a_p * a_q


istree(ap_prod)
exprhead(ap_prod)
operation(ap_prod)
arguments(ap_prod)
similarterm(ap_prod, OperatorProduct, (a_q,a_q))

substitute(a(p) * a(q), Dict(p => -q))