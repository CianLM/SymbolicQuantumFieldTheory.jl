struct Operator{F <: Field} <: OperatorSym
    name::Symbol
    indices::Tuple{Vararg{SymorNum}}
    adjoint::Bool

    function (op::AbstractOperator)(index::SymorNum, adjoint::Bool=false)
        println("$op with index $index is $(new{op.field}(op.name, (index,), adjoint))")
        return new{op.field}(op.name, (index,), adjoint)
    end

    function (op::AbstractOperator)(adjoint::Bool = false, indices::SymbolicUtils.Symbolic...)
        println("... init $op with adjoint $adjoint and indices $indices is $(new{op.field}(op.name, indices, adjoint))")
        return new{op.field}(op.name, indices, adjoint)
    end

    # function (op::AbstractOperator)(indices::Tuple{SymbolicUtils.Symbolic}, adjoint::Bool=false)
    #     println("Tuple of indices $indices passed to $op is $(new{op.field}(op.name, indices, adjoint))")
    #     return new{op.field}(op.name, indices, adjoint)
    # end

    # function Operator(op::AbstractOperator, indices::Tuple{SymbolicUtils.Symbolic}, adjoint::Bool=false)
    #     # println("Operator with name $(op.name), indices $indices, adjoint $adjoint is $(new{op.field}(op.name, indices, adjoint))")
    #     println("Operator $op $indices $adjoint")
    #     return new{op.field}(op.name, indices, adjoint)
    # end

    function Operator{F}(name::Symbol, indices::Tuple{Vararg{SymorNum}}, adjoint::Bool) where F <: Field
        # println("Operator with name $name, indices $indices, adjoint $adjoint is $(new{F}(name, indices, adjoint))")
        println("Operator: $(new{F}(name, indices, adjoint)): $name $indices $adjoint")
        return new{F}(name, indices, adjoint)
    end
    
    Operator() = new{Field}(:I, (), false)
    Operator{F}() where F <: Field = new{F}(:I, (), false)
    Base.one(::Type{T} where T <: OperatorSym) = new{Field}(:I, (), false)
    Base.one(::Type{T} where T <: Operator{F}) where F <: Field = new{F}(:I, (), false)
end
field(op::Operator{F}) where F <: Field = F
length(op::Operator) = 1 # for compatibility with OperatorProduct

function Base.show(io::IO, s::Operator)
    if s == one(Operator)
        print(io, "I")
    else
        print(io, s.name)
        if length(s.indices) > 0
            subscript = join(s.indices, ",")
            length(subscript) > 1 ? print(io, "_{$subscript}") : print(io, "_$subscript")
        end
        if s.adjoint
            print(io, "^†")
        end
    end
    # print(io, "$(s.name)_$(s.indices...)$("^†" ^ Int(s.adjoint))")
end

begin "TermInterface"

    function istree(x::Operator)
        println("Is tree called on $x")
        return x != one(Operator)
    end

    function exprhead(x::Operator)
        println("Exprhead called on $x")
        return :call
    end

    function operation(x::Operator)
        println("Operation called on $x")
        return AbstractOperator(ScalarField, x.name)
    end

    function arguments(x::Operator)
        println("Arguments called on $x")
        return (x.adjoint, x.indices...)
        # return x.indices
    end

    function metadata(x::Operator)
        println("Metadata called on $x")
        return nothing
    end

    function similarterm(t::Operator, f, args, symtype; metadata=nothing)
        println("similar term called with $f, $args, $symtype, $metadata, $exprhead result: $(t.adjoint ? f(args...)' : f(args...))")
        return f(args...)
    end

end

ishermitian(x) = false 

function Base.:(==)(x::Operator, y::Operator)
    return isequal(x.name, y.name) && isequal(x.indices, y.indices) && (ishermitian(x) || isequal(x.adjoint, y.adjoint))
end

function Base.isequal(x::Operator, y::Operator)
    return isequal(x.name, y.name) && isequal(x.indices, y.indices) && (ishermitian(x) || isequal(x.adjoint, y.adjoint))
end

^(a::Operator, b::Number) = OperatorPower(a, b)

function Base.hash(x::Operator, h::UInt=UInt(0))
    h = Base.hash(string(x.name), h)
    h = Base.hash(string(x.indices), h)
    h = Base.hash(x.adjoint, h)
    return h
end


