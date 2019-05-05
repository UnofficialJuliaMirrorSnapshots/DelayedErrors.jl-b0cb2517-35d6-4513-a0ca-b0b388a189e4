module DelayedErrors

export push_delayed_error, pop_delayed_errors

struct DelayedError
    message::T1 where T1 <: AbstractString
    dict::T2 where T2 <: AbstractDict
    bt::T3 where T3
    st::T4 where T4
end

@noinline function DelayedError(
        message::T1,
        dict::T2,
        )::DelayedError where
        T1 <: AbstractString where
        T2 <: AbstractDict
    bt = backtrace()
    st = stacktrace(bt)
    x = DelayedError(
        message,
        dict,
        bt,
        st,
        )
    return x
end

@noinline function __init__()::Nothing
    global delayed_error_list = Vector{DelayedError}()
    return nothing
end

"""
"""
function push_delayed_error end

"""
"""
function pop_delayed_errors end

@noinline function push_delayed_error(
        message::S;
        kwargs...
        )::Nothing where S <: AbstractString
    x = DelayedError(message, Dict(kwargs...),)
    global delayed_error_list
    push!(delayed_error_list, x,)
    @error("Pushed delayed error: $(x.message)", x.dict...)
    Base.show_backtrace(stderr, x.bt,)
    println(stderr)
    println(stderr)
    return nothing
end

@noinline function push_delayed_error(
        message::Vararg{Any,N};
        kwargs...
        )::Nothing where {N}
    push_delayed_error(Main.Base.string(message); kwargs...)
    return nothing
end

@noinline function pop_delayed_errors()::Nothing
    global delayed_error_list
    if isempty(delayed_error_list)
        @debug("There were no delayed errors to pop.")
    else
        while !isempty(delayed_error_list)
            x = popfirst!(delayed_error_list)
            @error("Popped delayed error: $(x.message)", x.dict...)
            Base.show_backtrace(stderr, x.bt,)
            println(stderr)
            println(stderr)
        end
        error("There were one or more delayed errors.")
    end
    return nothing
end

end # end module DelayedErrors
