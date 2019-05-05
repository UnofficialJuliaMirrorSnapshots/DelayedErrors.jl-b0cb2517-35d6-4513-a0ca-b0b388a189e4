import Test

using DelayedErrors

pop_delayed_errors()

push_delayed_error("This is ", "a test.", a = 1, b = "2",)

Test.@test_throws(
    ErrorException,
    pop_delayed_errors(),
    )
