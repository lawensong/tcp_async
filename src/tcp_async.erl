%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 十一月 2015 21:56
%%%-------------------------------------------------------------------
-module(tcp_async).
-author("Administrator").

%% API
-export([open/4]).

open(Protocol, Port, Options, MFArgs)->
  tcp_async_sup:start_listen(Protocol, Port, Options, MFArgs).
