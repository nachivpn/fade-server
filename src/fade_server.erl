-module(fade_server).
-compile(export_all).

% -export([newtask/3,result/3,command/3,hello/3]).

newtask(Sid, Env, In) ->
    {struct,[{"main_key",MainKey},{"tar_key",TarKey},{"module",Module},{"ser_key",SerKey}]} = mochijson:decode(In),
    TId = wpool:submit(work(TarKey,MainKey,Module,SerKey)),
    RespStr = format("{\"tid\" : \"~s\"}",[TId]),
    mod_esi:deliver(Sid, [RespStr]).

result(Sid,Env,In) ->
    {struct,[{"tid",TId}]} = mochijson:decode(In),
    Result = wpool:get_result(TId),
    RespStr = format("{\"result\" : \"~s\"}",[Result]),
    mod_esi:deliver(Sid, [RespStr]).

command(Sid,Env,In) ->
    {struct,[{"command",Cmd}]} = mochijson:decode(In),
    TId = wpool:submit(fun() ->os:cmd(Cmd) end),
    RespStr = format("{\"tid\" : \"~s\"}",[TId]),
    mod_esi:deliver(Sid, [RespStr]).

hello(Sid, Env, In) ->
    mod_esi:deliver(Sid, ["hello"]).

work(TarKey, MainKey, Module, SerKey) ->
    fun() ->
        OutSerKey = lists:concat([util:uuid(),".py"]),
        os:cmd(lists:concat(["./deploy.sh ", TarKey, " ", MainKey, " ", Module, " ", SerKey, " ", OutSerKey]))
    end.

format(Str,Value) ->
    lists:flatten(io_lib:format(Str,Value)).