-module(fib).
-compile(export_all).

fibRun() ->
    T1 = wpool:submit(fun() -> fib:fib(1000000) end),
    T2 = wpool:submit(fun() -> fib:fib(1000000) end),
    R1 = wpool:get_result(T1),
    io:format("~p",[R1]),
    R2 = wpool:get_result(T2),
    io:format("~p",[R2]).

%% the following code was shameless copy pasted from google search results. hackathons, sigh.

fib(N) -> fib_iter(N, 0, 1).

fib_iter(0, Result, _Next) -> Result;
fib_iter(Iter, Result, Next) when Iter > 0 ->
fib_iter(Iter-1, Next, Result+Next).