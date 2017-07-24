-module(wpool).
-export([init_pool/0,submit/1,get_result/1]).
-import(util,[make_id/1]).

-record(task, {sid, tid = "", work}).

%% API FUNCTION
% submit: W() -> Task_Id
submit(W) ->
    MartinId = spawn_link(
        fun() ->
            martin()
        end
    ),
    TId = util:make_id(MartinId),
    pool ! {submit_task_req, #task{sid=MartinId, tid=TId, work=W}},
    TId.

%% API FUNCTION
% get_result: Task_Id -> Result
get_result(TId) ->
    MartinId = util:get_pid(TId),
    MartinId ! {get_task_res, TId, self()},
    receive
        {martin_resp, TId, Result} -> Result
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% INTERNAL FUNCTIONS %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Martin waits for results
martin() ->
    TId = util:make_id(self()),
    receive
        {task_resp, TId, Result} ->
            receive
                {get_task_res, TId, SId}  -> 
                    SId ! {martin_resp, TId, Result}
            end
    end.

% pool master: [{WorkerPid,T}] -> [{WorkerPid,T}]
master(WorkRegistry) ->
    receive
        {work_response, Result, WorkerPid} ->
            {WorkerPid, T} = proplists:lookup(WorkerPid, WorkRegistry),
            WorkRegistry_ = lists:delete({WorkerPid, T},WorkRegistry),
            T#task.sid ! {task_resp,T#task.tid,Result},
            master(WorkRegistry_);
        {submit_task_req, T} ->
            receive
                 {get_work, WorkerPid} ->
                    WorkerPid ! {new_work, T#task.work},
                    WorkRegistry_ = [ {WorkerPid, T} | WorkRegistry ],
                    master(WorkRegistry_)
            end;
        {'EXIT', DeadWorkerPid, _} ->
            receive
                {get_work, WorkerPid} ->
                    {DeadWorkerPid,T} = proplists:lookup(DeadWorkerPid,WorkRegistry),
                    WorkRegistry_ = lists:delete({DeadWorkerPid,T},WorkRegistry),
                    WorkerPid ! {new_work, T#task.work},
                    WorkRegistry__ = [ {WorkerPid, T} | WorkRegistry_ ],
                    master(WorkRegistry__)
            end
    end.

% Worker: MasterPid -> MasterPid
worker(Master) ->
    Master ! {get_work, self()},
    receive
        {new_work,W} ->
            Master ! {work_response,W(),self()}, 
            worker(Master);
        {no_work,Reason} -> exit(Reason)
    end.

%% spawn master
init_pool() ->
    Nodes = [node() | nodes()],
    Master = spawn_link(
        fun() -> 
            process_flag(trap_exit, true), 
            [initNode(Node,self(),1) || Node <- Nodes], 
            master([]) 
        end),
    register(pool,Master).

%% initialize node: (Node,MasterPid,Int) -> [WorkerPid]
initNode(Node,Master,WorkerSize) -> [spawn_worker(Node,Master) || _ <- lists:seq(1,WorkerSize)].

%% spawn_worker: (Node,MasterPid) -> worker_pid
spawn_worker(Node,Master) -> spawn_link(Node, fun() -> worker(Master) end).