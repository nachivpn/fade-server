-module(obj_storage).
-export([download/3]).

download(Uname, Pass, FilePath) ->
    inets:start(),
    {ok, Pid} = inets:start(ftpc, [{host, "fade-ftp-server.cern.ch"}, {port, "21"}]),
    ftp:user(Pid, "fade", "fade"),
    print_remote_info(Pid),
    %ftp:cd(Pid, "appl/examples"),
    %ftp:lpwd(Pid),
    %ftp:lcd(Pid, "~/examples"),
    ftp:recv(Pid, FilePath),
    inets:stop(ftpc, Pid).

print_remote_info(Pid) ->
    {_, RemoteDir} = ftp:pwd(Pid),
    io:format("pwd:~n~p~n", [RemoteDir]),
    {_, RemoteLs} = ftp:ls(Pid),
    io:format("ls:~n~s~n", [RemoteLs]).

