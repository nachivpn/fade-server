% Python plugin
-module(fade_py).
-compile(export_all).

work(In) ->
    {struct,[{"main_key",MainKey},{"tar_key",TarKey},{"module",Module},{"ser_key",SerKey}]} = mochijson:decode(In),
    fun() ->
        OutSerKey = lists:concat([util:uuid(),".py"]),
        os:cmd(lists:concat(["./deploy.sh ", TarKey, " ", MainKey, " ", Module, " ", SerKey, " ", OutSerKey]))
    end.