
-module(key_value_store_storage).

-behaviour(gen_server).

%% Public functions
-export([start_link/0, set/2, get/1, clear/1]).

%% gen_server callbacks
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

%% Start the storage process
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% Store or update a value
set(Key, Value) ->
    gen_server:call(?MODULE, {set, Key, Value}).

%% Retrieve a value
get(Key) ->
    gen_server:call(?MODULE, {get, Key}).

%% Delete a key
clear(Key) ->
    gen_server:call(?MODULE, {clear, Key}).

%% Initialize empty storage
init([]) ->
    {ok, #{}}.

%% Handle SET
handle_call({set, Key, Value}, _From, State) ->
    NewState = State#{Key => Value},
    {reply, ok, NewState};

%% Handle GET
handle_call({get, Key}, _From, State) ->
    case maps:find(Key, State) of
        {ok, Value} ->
            {reply, {ok, Value}, State};
        error ->
            {reply, {error, not_found}, State}
    end;

%% Handle CLEAR
handle_call({clear, Key}, _From, State) ->
    case maps:is_key(Key, State) of
        true ->
            {reply, ok, maps:remove(Key, State)};
        false ->
            {reply, {error, not_found}, State}
    end;

%% Handle unsupported requests
handle_call(_Request, _From, State) ->
    {reply, {error, unsupported_request}, State}.

%% Handle asynchronous messages
handle_cast(_Request, State) ->
    {noreply, State}.

%% Handle other messages
handle_info(_Info, State) ->
    {noreply, State}.

%% Cleanup
terminate(_Reason, _State) ->
    ok.

%% Support code upgrades
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
