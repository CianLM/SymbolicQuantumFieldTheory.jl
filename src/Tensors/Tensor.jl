# 𝜇𝜈𝜌𝜏𝛼𝛽𝛾𝜒𝜀𝜈𝜂𝜄𝜑𝜓𝜉𝜁𝜅𝜃𝜎𝜆𝜋𝜔
struct Tensor{F <: Field}
    symbol::Symbol
    indices::Vector{Index}
    metadata::Union{NamedTuple,Nothing}

    function Tensor{F}(symbol::Symbol, indices::Vector{Index}; metadata=nothing) where F <: Field
        @assert length(string(symbol)) == 1 "Tensor symbol must be a single character."
        @assert index_legal(indices)
        new{F}(symbol, indices, metadata)
    end


    Tensor{F}(symbol::Symbol, indices::Index...; metadata=nothing) where F <: Field = new{F}(symbol, [indices...], metadata)
    ^(symbol::Symbol, index::Index; metadata=nothing) = Tensor(symbol, [index], metadata)
    
    function(t::AbstractTensor{F})(indices::Index...; metadata=nothing) where F <: Field
        # tensor_field(t)
        return Tensor{F}(t.name, [indices...]; metadata)
    end
    # # TODO on abstract tensor instantiation add sym_ as an abstract tensor that creates covariantly

    Base.one(::Type{Tensor}) = Tensor(:I, Index[])
end

function Tensor(symbol::Symbol, indices::Vector{Index}; metadata=nothing)
    # print whether symbol is defined in calling scope and if it is an AbstractTensor
    field = ((Main.isdefined(Main, symbol)) && (eval(symbol) isa AbstractTensor)) ? tensor_field(eval(symbol)) : Field
    Tensor{field}(symbol, indices; metadata)
end
# typeof(A)
# typeof(@Tensor A_ϕ)
# typeof(@Tensor A^ϕ)
# typeof(@Tensor B_ϕ)
# typeof(@Tensor B^ϕ)

MetricTensor(indices::Vector{Index}) = length(indices) == 2 ? Tensor{Metric}(:g, indices) : error("Metric Tensor must have two indices.")
Partial(index::Index) = Tensor{Derivative}(:∂, index)
∂(index::Index = Index(:μ)) = Partial(index)
g(μ::Index = Index(:μ), ν::Index = Index(:ν)) = MetricTensor([μ, ν])
# typeof(∂())
# typeof(g())

# g(@Index(ρ), @Index(ϕ))
# g()

tensor_field(A::Tensor{F}) where F <: Field = F


function Base.show(io::IO, tensor::Tensor)
    print(io, tensor.symbol)
    if length(tensor.indices) > 0
        prev_index = -1
        for index in tensor.indices
            if index.covariant != prev_index
                print(io, index.covariant ? "_" : "^")
                prev_index = index.covariant
            end
            print(io, index.symbol)
        end
    end
end

function index_legal(tensor::Vector{Index})
    indices = Dict{Symbol,Int}()
    for index in tensor
        if !haskey(indices, index.symbol)
            indices[index.symbol] = index.covariant
        else
            @assert indices[index.symbol] < 2 "Index $index appears more than twice."
            @assert index.covariant != indices[index.symbol] "Index $index appears twice in a $(Bool(indices[index.symbol]) ? "co" : "contra")variant position."
            indices[index.symbol] = 2
        end
    end
    return true
end

# # usage: @Tensor A^μ where A is a symbol and μ is an index
# macro Tensor(expr::Expr)
#     # $(Expr(:quote, Symbol(string(var))))
#     # println(expr.args,expr.head)
#     if expr.head == :call && expr.args[1] == :^
#         # println(length(string(expr.args[2])), string(expr.args[2])[2])
#         if length(string(expr.args[2])) > 1 && string(expr.args[2])[2] == '_'
#             symbol = Symbol(string(expr.args[2])[1])
#             indices = Index.(split(string(expr.args[2])[3:end], ""))
#         else
#             @assert length(string(expr.args[2])) == 1 "Tensor symbol must be a single character."
#             symbol = expr.args[2]
#             indices = Index[]
#             # return Tensor(expr.args[2], Index.(Symbol.(split(string(expr.args[3]), r"[\^_]+"))))
#         end
#         # if the symbol has been instantiated as an AbstractTensor, use that field
#         # Note that we are in the macro here and thus must escape the symbol to the variable it represents
#         # println("Symbol: ", symbol)
#         # println("Attached Indices: ", indices)
#         # parse remaining indices in args[3] of the form [^]a_b^c_d_e
#         head = expr.args[3]
#         while hasproperty(head,:args) && head.args[1] == :^
#             # println("head: ", head)
#             str_head = [ v for (i,v) in enumerate(string(head.args[2]))]
#             if length(str_head) == 1
#                 indices = [indices..., Index(str_head[1], false)]
#             else
#                 underscore = findfirst('_' .== str_head)
#                 # println("underscore: $underscore")
#                 underscore = underscore === nothing ? length(string(head)) : underscore
#                 usless_str = [str_head[1:underscore-1]..., str_head[underscore+1:end]...]
#                 # println("usless_str: $usless_str")
#                 indices = Index[indices..., [Index(v,i ≥ underscore) for (i,v) in enumerate(usless_str) ]...]
#             end
#             head = head.args[3]
#         end
#         # println("final head: ", head)
#         str_head = [ v for (i,v) in enumerate(string(head))]
#         # println("str_head: ", str_head, typeof(string(head)), length(string(head)))
#         if length(str_head) == 1
#             indices = [indices..., Index(str_head[1], false)]
#         else
#             underscore = findfirst('_' .== str_head)
#             underscore = underscore === nothing ? length(string(head)) + 1 : underscore
#             # println("underscore: $underscore")
#             usless_str = [str_head[1:underscore-1]..., str_head[underscore+1:end]...]
#             # println("usless_str: $usless_str")
#             indices = Index[indices..., [Index(v,i ≥ underscore) for (i,v) in enumerate(usless_str) ]...]
#         end
#         # println("Indices: $indices")
#         # bricks julia lol return Tensor{:($(@check_field esc(symbol)))}(symbol, [indices...])
#         # println(tensor_field(eval(esc(symbol))))
#         return Tensor(symbol, indices)
#         # also crashed julia 🙀, @check_field :(symbol)
#     end
#     error("Invalid Tensor expression: $expr. Must be of the form A^μ_ν^ρτ")
# end

# https://docs.julialang.org/en/v1/manual/metaprogramming/
"Usage: `@Tensor A^μν_ρ^τ` where `A` is a symbol and `μ,ν,ρ,τ` are indices."
macro Tensor(expr::Expr)
    # @show expr
    symbol = string(expr)[1]
    indices = []
    if length(string(expr.args[2])) > 1 && 
       string(expr.args[2])[nextind(string(expr.args[2]),1)] == '_'
        push!(indices, [ v => true for v in split(string(expr.args[2])[nextind(string(expr.args[2]),1,2):end], "")]...)
    else
        @assert length(string(expr.args[2])) == 1 "Tensor symbol must be a single character, not $(expr.args[2])"
    end
    head = expr.args[3]
    while hasproperty(head, :args) && head.args[1] == :^
        # @show head
        indices = parse_indices(head, indices, false)

        head = head.args[3]
    end
    # @show head
    indices = parse_indices(head, indices, true)
    return Tensor(
            Symbol(symbol),
            Index[Index(index.first, index.second) for index in indices]
        )
        # indices = Index[indices..., [Index(v,i ≥ underscore) for (i,v) in enumerate(usless_str) ]...]
end

function parse_indices(head, indices, leaf)
    str_head = [ v for (i,v) in enumerate(string(leaf ? head : head.args[2])) ]
    # @show str_head
    if length(str_head) == 1
            indices = [indices..., str_head[1] => false]
    else
        underscore = findfirst('_' .== str_head)
        # underscore = underscore === nothing ? length(string(head)) : underscore
        if underscore !== nothing
            underscoreless_str = [str_head[1:underscore-1]..., str_head[underscore+1:end]...]
            indices = [indices..., [ v => i ≥ underscore for (i,v) in enumerate(underscoreless_str)]...]
        else
            indices = [indices..., [ v => false for (i,v) in enumerate(str_head)]...]
        end
    end
    return indices
end

"Usage: `@Tensor A_bc` where `A` is a symbol and `b`/`c` are indices."
macro Tensor(expr::Symbol)
    length(string(expr)) == 1 && return Tensor(expr, Index[])
    # split the symbol at the underscore
    symbol, indices = split(string(expr), "_")
    return Tensor(Symbol(symbol), Index.(Symbol.(split(indices, ""))))
end

begin "TermInterface"
    function istree(x::Tensor)
        #println("Is tree called on $x")
        return true
    end

    function exprhead(x::Tensor)
        #println("Exprhead called on $x")
        return :call
    end

    function operation(x::Tensor)
        #println("Operation called on $x")
        return AbstractTensor(x.symbol)
    end

    function arguments(x::Tensor)
        #println("Arguments called on $x")
        return (x.indices)
        # return x.indices
    end

    function metadata(x::Tensor)
        #println("Metadata called on $x")
        return nothing
    end

    function similarterm(t::Tensor, f, args; exprhead=:call, metadata=nothing)
        #println("similar term called with $f, $args, $symtype, $metadata, $exprhead result: $(t.adjoint ? f(args...)' : f(args...))")
        return f(args...)
    end
end


"""
`raise(tensor, index)`

Raise an index in a given tensor.

# Example
```julia
julia> μ = @Index μ
μ

julia> g()
g_μν

julia> raise(g(), μ)
g^μ_ν
```
"""
function raise(tensor::Tensor{F}, index::Index) where F <: Field
    # raise the specified index if it exists
    for (i,ind) in enumerate(tensor.indices)
        if ind.symbol == index.symbol
            indices = copy(tensor.indices)
            indices[i] = Index(index.symbol, false)
            return Tensor{F}(tensor.symbol, indices)
        end
    end
    error("Index $index not found in $tensor")
end

function raiseAll(tensor::Tensor{F}) where F <: Field
    free = free_indices(tensor)
    indices = copy(tensor.indices)
    for (i,ind) in enumerate(tensor.indices)
        if ind ∈ free
            indices[i] = Index(ind.symbol, false)
        end
    end
    return Tensor{F}(tensor.symbol, indices)
end

"Lower an index in a given tensor."
function lower(tensor::Tensor{F}, index::Index) where F <: Field
    # lower the specified index if it exists
    for (i,ind) in enumerate(tensor.indices)
    #   println(ind.symbol, index.symbol, ind.symbol == index.symbol)
        if ind.symbol == index.symbol
            indices = copy(tensor.indices)
            indices[i] = Index(index.symbol, true)
            return Tensor{F}(tensor.symbol, indices)
        end
    end
    error("Index $index not found in $tensor")
end

function lowerAll(tensor::Tensor{F}) where F <: Field
    free = free_indices(tensor)
    indices = copy(tensor.indices)
    for (i,ind) in enumerate(tensor.indices)
        if ind ∈ free
            indices[i] = Index(ind.symbol, true)
        end
    end
    return Tensor{F}(tensor.symbol, indices)
end


function Base.:(==)(x::Tensor, y::Tensor)
    return isequal(x, y)
end

function Base.isequal(x::Tensor, y::Tensor)
    return hash(x) == hash(y)
end

function Base.hash(x::Tensor, h::UInt=UInt(0))
    h = Base.hash(string(x.symbol), h)
    h = Base.hash(string(x.indices), h)
    return h
end

# @latexrecipe function f(x::Tensor)
#     env --> :equation
#     cdot --> false
#     if x == one(Operator)
#         return "I"
#     else
#         return Expr(:call, :*, string(x.symbol), (length(x.indices) > 0 ? "_{$(join(x.indices, ""))}" : ""))
#     end
# end
@latexrecipe function f(tensor::Tensor)
    env --> :equation
    cdot --> false
    if tensor == one(Operator)
        return "I"
    else
        return Expr(:call, :*, string(tensor.symbol), (length(tensor.indices) > 0 ? join(["{}$(index.covariant ? '_' : '^'){$(index)}" for index in tensor.indices],"") : "")
        )
    end
end


macro Tensors(exprs::Union{Symbol,Expr}...)
    return Expr(:tuple, [:(@Tensor $expr) for expr in exprs]...)
end

a, b, c = @Tensors A^🐲_🐲^f B_μ C^ϕχ



function signature(tensor::Tensor)
    free = Set{Index}()
    contracted = 0
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
    return (free, contracted)
end

free_indices(x::Tensor) = signature(x)[1]

contracted_indices(x::Tensor) = setdiff(Set(x.indices), signature(x)[1])
# function contracted_indices(x::Tensor)
#     free = Set{Index}()
#     contracted = Set{Index}()
#     for index in tensor.indices
#         if Index(index.symbol, !index.covariant) ∈ free
#             push!(contracted, Index(index.symbol, true))
#         else
#             push!(free, index)
#         end
#     end
#     return contracted
# end

"Relabel all copies of an index `μ` to another index `ν` in a tensor."
function relabel(μ::Symbol, ν::Symbol, x::Tensor)
    desired_index(index::Index) = index.symbol == μ
    rule = @rule ~index::desired_index => Index(ν, index.covariant; dim=index.dim)
    new_indices = Metatheory.PassThrough(rule).(arguments(x))
    # println(new_indices)
    return similarterm(x, operation(x), new_indices)
end

# [Tensor{Metric}(:g, [Index(:μ), Index(:ν)]), @Tensor A_💜]
# # 💙 💚 💛
# tensor_field(@Tensor g^μ)
# typeof(A)

# gc = g() * @Tensor(g^μν)
# relabel(:μ, :ν, @Tensor(g^μ_ν))
# μ


# gc + gc + @Tensor(g^μν) * 2