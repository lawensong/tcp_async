%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 十一月 2015 22:00
%%%-------------------------------------------------------------------
-module(tcp_async_listen_sup).
-author("Administrator").

-behaviour(supervisor).

%% API
-export([start_link/4]).

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
start_link(Protocol, Port, Options, MFArgs) ->
  {ok, Sup} = supervisor:start_link(?MODULE, []),
  {ok, Connsup} = supervisor:start_child(Sup, {conn_sup, {tcp_async_conn_sup, start_link, [Options, MFArgs]},
    transient, infinity, supervisor, [tcp_async_conn_sup]}),
  {ok, Acceptsup} = supervisor:start_child(Sup, {tcp_async_accept_sup, {tcp_async_accept_sup, start_link, [Connsup]},
    transient, infinity, supervisor, [tcp_async_accept_sup]}),
  {ok, _Listen} = supervisor:start_child(Sup, {listener, {tcp_async_listen, start_link, [Protocol, Port, Options, Acceptsup]},
    transient, 16#ffffffff, worker, [tcp_async_listen]}),
  {ok, Sup}.

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
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]
  }} |
  ignore |
  {error, Reason :: term()}).
init([]) ->
  {ok, {{rest_for_one, 10, 100}, []}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
