%%%-------------------------------------------------------------------
%% @doc key_value_store public API
%% @end
%%%-------------------------------------------------------------------

-module(key_value_store_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    key_value_store_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
