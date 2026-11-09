%%%-------------------------------------------------------------------
%% @doc key_value_store top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(key_value_store_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{
        strategy => one_for_one,
        intensity => 1,
        period => 5
    },
    ChildSpecs = [
        #{
            id => key_value_store_storage,
            start => {key_value_store_storage, start_link, []},
            restart => permanent,
            shutdown => 5000,
            type => worker,
            modules => [key_value_store_storage]
        },
        #{
            id => key_value_store_http,
            start => {key_value_store_http, start_link, []},
            restart => permanent,
            shutdown => 5000,
            type => worker,
            modules => [key_value_store_http]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
