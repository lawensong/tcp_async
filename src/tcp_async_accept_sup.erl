%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 十一月 2015 22:12
%%%-------------------------------------------------------------------
-module(tcp_async_accept_sup).
-author("Administrator").

-behaviour(supervisor).

%% API
-export([start_link/1, start_accptor/2]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
start_link(Connsup) ->
  supervisor:start_link(?MODULE, [Connsup]).

start_accptor(AcceptSup, LSock) ->
  supervisor:start_child(AcceptSup, [LSock]).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
init([Connsup]) ->
  {ok, {{simple_one_for_one, 1000, 3600},
    [{tcp_async_accept, {tcp_async_accept, start_link, [Connsup]},
    transient, 5000, worker, [tcp_async_accept]}]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
