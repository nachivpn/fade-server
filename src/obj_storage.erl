-module(obj_storage).
-export([download/3]).

download(Uname, Pass, FilePath) ->
    inets:start(),
    {ok, Pid} = inets:start(ftpc, [{host, "fade-ftp-service.cern.ch"}, {port, "21"}]),
    ftp:user(Pid, Uname, Pass),
    ftp:cd(Pid, "/pub/fade-bucket/"),
    print_remote_info(Pid),
    ftp:recv(Pid, FilePath),
    inets:stop(ftpc, Pid).

print_remote_info(Pid) ->
    {_, RemoteDir} = ftp:pwd(Pid),
    io:format("pwd:~n~p~n", [RemoteDir]),
    {_, RemoteLs} = ftp:ls(Pid),
    io:format("ls:~n~s~n", [RemoteLs]).

