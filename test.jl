using Revise
using QFT
using Symbolics
import QFT.comm
@syms a b

@field TestField
@operators TestField j k
j(a) * k(b)'
@comm [j(a), k(b)'] = j(b) * k(b)'
comm(j(b), k(a)')



module Bruh
    y = 2
    macro g_fn(name, args...)
        name_str = "$name"
        argstup = Tuple(args)
        quote
            println($__module__, " ", $y)
            function $(esc(name))($(map(esc, argstup)...))
                # println($name_str)
                map(println, [($(map(esc, argstup)...))])
                println(Base.eval($__module__, :(y)))
                return 8 #Base.eval($__module__, :(y))
            end
        end
    end
    macro testeval(arg1, arg2)
        return quote
                    function $(esc(:test))($(esc(:u1))::Int, $(esc(:u2))::Int)
                        println("t = 28")
                        println("$u1, $u2")
                        println(join([$(esc(arg1)), $(esc(arg2)), typeof($(esc(arg1))), typeof($(esc(arg2)))], " "))
                        println("In macro scope: $y")
                        println("In module scope: ", Base.eval($__module__, :(y)))
                        return Base.eval($__module__, :(y))
                    end
        end
    end
    macro make_fn(name, args...)
        name_str = "$name"
        argstup = Tuple(args)
     
        quote
            function $(esc(name))($(map(esc, argstup)...))
                println($name_str)
                map(println, [($(map(esc, argstup)...))])
            end
        end
     end
end
y = 1

using .Bruh: @g_fn, @make_fn, @testeval as @t28
f(x) = x^2
@t28(f("one"), "two")
test(2,3)
test(2.0,3)
# join is a function in Base

@g_fn(h3)
h3()
@make_fn(h4, arg1)
h4(5)

@h_fn(h6)
h5(5)

@bruh [j(a), k(b)'] = 1

comm(j(a), k(b)')
@__MODULE__