%%%-------------------------------------------------------------------
%% @doc fade_server public API
%% @end
%%%-------------------------------------------------------------------

-module(fade_server_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-import(wpool,[submit/1,get_result/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    X = fade_server_sup:start_link(),
    wpool:init_pool(),
    inets:start(),
    {Httpd_State,Httpd_Pid} = inets:start(httpd, [{port, 8099}, {server_name, "localhost"}, {document_root, "."}, 
        {modules,[mod_esi]},{server_root, "."}, {erl_script_timeout, 1800}, {erl_script_alias, {"/api", [fade_server, io]}}]),
    X.

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
