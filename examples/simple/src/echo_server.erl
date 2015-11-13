%%%-----------------------------------------------------------------------------
%%% @Copyright (C) 2014-2015, Feng Lee <feng@emqtt.io>
%%%
%%% Permission is hereby granted, free of charge, to any person obtaining a copy
%%% of this software and associated documentation files (the "Software"), to deal
%%% in the Software without restriction, including without limitation the rights
%%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%%% copies of the Software, and to permit persons to whom the Software is
%%% furnished to do so, subject to the following conditions:
%%%
%%% The above copyright notice and this permission notice shall be included in all
%%% copies or substantial portions of the Software.
%%%
%%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%%% SOFTWARE.
%%%-----------------------------------------------------------------------------
%%% @doc
%%% Simple Echo Server.
%%%
%%% @end
%%%-----------------------------------------------------------------------------
-module(echo_server).

-export([start/0, start/1]).

%%callback 
-export([start_link/1, init/1, loop/2]).

-define(TCP_OPTIONS, [
		binary,
		{packet, raw},
		%{buffer, 1024},
		{reuseaddr, true},
		{backlog, 1024},
		{nodelay, false}]).

%%------------------------------------------------------------------------------
%% @doc
%% Start echo server.
%%
%% @end
%%------------------------------------------------------------------------------
start() ->
    start(5000).
%% shell
start([Port]) when is_atom(Port) ->
    start(list_to_integer(atom_to_list(Port)));
start(Port) when is_integer(Port) ->
    [ok = application:start(App) || App <- [sasl, tcp_async]],
    Access = application:get_env(tcp_async, access, [{allow, all}]),
    SockOpts = [{access, Access},
                {acceptors, 32},
                {shutdown, infinity},
                {max_clients, 1000000},
                {sockopts, ?TCP_OPTIONS}],
    MFArgs = {?MODULE, start_link, []},
  tcp_async:open(echo, Port, SockOpts, MFArgs).

%%------------------------------------------------------------------------------
%% @doc
%% eSockd callback.
%%
%% @end
%%------------------------------------------------------------------------------
start_link(SockArgs) ->
	{ok, spawn_link(?MODULE, init, [SockArgs])}.

init(SockArgs) ->
    {ok, NewSock} = tcp_async_conn:accept(SockArgs),
	loop(NewSock, state).

loop(Sock, State) ->
	case gen_tcp:recv(Sock, 0) of
		{ok, Data} ->
			{ok, _PeerName} = inet:peername(Sock),
%% 			io:format("~s - ~s~n", [tcp_async_net:format(peername, PeerName), Data]),
			gen_tcp:send(Sock, Data),
			loop(Sock, State);
		{error, Reason} ->
			io:format("tcp ~s~n", [Reason]),
			{stop, Reason}
	end.


