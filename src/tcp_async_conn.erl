%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 2015 11:27
%%%-------------------------------------------------------------------
-module(tcp_async_conn).
-author("Administrator").

%% API
-export([start_link/2]).
-export([call/2, ready/2, accept/1]).

start_link(Sock, MFArgs) ->
  case call(Sock, MFArgs) of
    {ok, Pid} -> {ok, Pid}
  end.

ready(Connpid, Sock) ->
  Connpid ! {socket_ready, Sock}.

accept(Sock) ->
  receive
    {socket_ready, Sock} -> {ok, Sock}
    end.

call(Sock, M) ->
  M:start_link(Sock).
