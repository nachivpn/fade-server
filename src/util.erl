-module(util).
-compile(export_all).

make_id(Pid) -> pid_to_list(Pid).

get_pid(TId) -> list_to_pid(TId).

upid(Pid) -> erlang:phash2({node(),Pid}).

uuid() -> erlang:phash2({node(),self(), now()}).