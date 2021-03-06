% Prepaped for the type of failure, when the process, which had asked for the data/resource, crashed.
% Checking with is_process_alive/1 function

-module(task24).
-export([start/0, dataStorageProc/2, dataItem1/0, dataItem2/0, dataItem3/0, proc/2]).

dataStorageProc(Data, ListOfProc) ->
	if
		ListOfProc /= [] ->
			FirstProcInQ = lists:last(ListOfProc),
			timer:sleep(1000),

			isAlive = is_process_alive(FirstProcInQ),

			if
				isAlive /= false ->
					FirstProcInQ ! {Data};
				true ->
					timer:sleep(1)
			end,

			dataStorageProc(Data, lists:droplast(ListOfProc));
	true ->
			timer:sleep(1)
	end,

	receive
		{RequestingProc, TypeOfLock} ->
			if
				TypeOfLock == "shared" ->

					isAlive = is_process_alive(RequestingProc),
					if
						isAlive /= false ->
							RequestingProc ! {Data};
						true ->
							timer:sleep(1)
					end,

					dataStorageProc(Data, ListOfProc);
				true -> %exlusive
					ListOfProcCur = [RequestingProc | ListOfProc],
					if
						ListOfProcCur == [RequestingProc] ->
							timer:sleep(1000), %some actions

							isAlive = is_process_alive(RequestingProc),
							if
								isAlive /= false ->
									RequestingProc ! {Data};
								true ->
									timer:sleep(1)
							end,

							dataStorageProc(Data, []);
						true ->
							dataStorageProc(Data, ListOfProcCur)
					end
			end
	end.

dataItem1() ->
	[1,2,3,4,5,6,7,8].
dataItem2() ->
	 "DataItem2".
dataItem3() ->
	 178.

proc(TypeOfLock, DataStorageProc) ->
	io:format("Process ~p is requesting data proc ~p with type of lock:~p~n", [self(), DataStorageProc, TypeOfLock]),
	DataStorageProc ! {self(), TypeOfLock},
	receive
		{Data} ->
			io:format("Process ~p got data ~p~n", [self(), Data])
	end.





start() ->
  register(dataStorageProc_1, spawn(task22, dataStorageProc, [dataItem1(), []])),
	register(dataStorageProc_2, spawn(task22, dataStorageProc, [dataItem2(), []])),
	register(dataStorageProc_3, spawn(task22, dataStorageProc, [dataItem3(), []])),

	register(proc_1, spawn(task24, proc, ["exclusive", dataStorageProc_1])),
	register(proc_2, spawn(task24, proc, ["exclusive", dataStorageProc_2])),
	register(proc_3, spawn(task24, proc, ["exclusive", dataStorageProc_2])),
	register(proc_4, spawn(task24, proc, ["exclusive", dataStorageProc_2])),
	register(proc_5, spawn(task24, proc, ["shared", dataStorageProc_3])).
