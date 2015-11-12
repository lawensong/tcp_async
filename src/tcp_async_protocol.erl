%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 十一月 2015 22:25
%%%-------------------------------------------------------------------
-module(tcp_async_protocol).
-author("Administrator").

%% API
-export([listen/2]).

listen(Port, SockOpt) ->
  gen_tcp:listen(Port, SockOpt).
