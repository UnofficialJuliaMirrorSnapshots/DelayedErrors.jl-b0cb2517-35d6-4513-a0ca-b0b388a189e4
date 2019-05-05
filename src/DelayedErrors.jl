module DelayedErrors

export push_delayed_error, pop_delayed_errors

struct DelayedError
    message::S where S <: AbstractString
    dict::T where T <: AbstractDict
end

function __init__()::Nothing
    global delayed_error_list = Vector{DelayedError}()
    return nothing
end

"""
"""
function push_delayed_error end

"""
"""
function pop_delayed_errors end

function push_delayed_error(
        message::S;
        kwargs...
        )::Nothing where S <: AbstractString
    x = DelayedError(message, Dict(kwargs...),)
    global delayed_error_list
    push!(delayed_error_list, x,)
    @error("Delaying this error until later: $(x.message)", x.dict...)
    return nothing
end

function push_delayed_error(
        message::Vararg{Any,N};
        kwargs...
        )::Nothing where {N}
    push_delayed_error(Main.Base.string(message); kwargs...)
    return nothing
end

function pop_delayed_errors()::Nothing
    global delayed_error_list
    if isempty(delayed_error_list)
        @debug("There were no delayed errors.")
    else
        while !isempty(delayed_error_list)
            x = popfirst!(delayed_error_list)
            @error("Delayed error from earlier: $(x.message)", x.dict...)
        end
        error("There were one or more delayed errors.")
    end
    return nothing
end

end # end module DelayedErrors
