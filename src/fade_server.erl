-module(fade_server).
-export([result/3,command/3,pytask/3]).

result(Sid,Env,In) ->
    {struct,[{"tid",TId}]} = mochijson:decode(In),
    Result = wpool:get_result(TId),
    RespStr = resultResp(Result),
    mod_esi:deliver(Sid, [RespStr]).

command(Sid,Env,In) ->
    {struct,[{"command",Cmd}]} = mochijson:decode(In),
    TId = wpool:submit(fun() ->os:cmd(Cmd) end),
    RespStr = tidResp(TId),
    mod_esi:deliver(Sid, [RespStr]).

%%%%
%% Language Plugins
%%%%

pytask(Sid, Env, In) ->
    TId = wpool:submit(fade_py:work(In)),
    RespStr = tidResp(TId),
    mod_esi:deliver(Sid, [RespStr]).

% jtask(Sid, Env, In) -> undefined.

% htask(Sid, Env, In) -> undefined.

%%%%
%% Response utility
%%%%

resultResp(Result) -> singleResp("result",Result).

tidResp(TId) -> singleResp("tid",TId).

singleResp(Field,Value) -> util:format("{\"~s\" : \"~s\"}",[Field,Value]).
