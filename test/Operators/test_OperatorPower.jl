a_p = a(p)
a_q = a(q)

ap2 = a_p^2


istree(ap2)
exprhead(ap2)
operation(ap2)
arguments(ap2)
similarterm(ap2, OperatorPower, (a_q,3))

substitute(a(p)^5, Dict(p => q))