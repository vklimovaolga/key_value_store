
-module(key_value_store_handler).

-export([init/2]).

init(Req0, State) ->
    Method = cowboy_req:method(Req0),

    handle_request(Method, Req0, State).

handle_request(<<"PUT">>, Req0, State) ->
    Key = cowboy_req:binding(key, Req0),

    {ok, Body, Req1} = cowboy_req:read_body(Req0),

    try jsx:decode(Body, [return_maps]) of
        #{<<"value">> := Value} ->
            ok = key_value_store_storage:set(Key, Value),

            Response = #{
                <<"key">> => Key,
                <<"value">> => Value
            },

            reply_json(200, Response, Req1, State);

        _ ->
            reply_json(
                400,
                #{<<"error">> => <<"Missing value field">>},
                Req1,
                State
            )
    catch
        _:_ ->
            reply_json(
                400,
                #{<<"error">> => <<"Invalid JSON">>},
                Req1,
                State
            )
    end;

handle_request(<<"GET">>, Req0, State) ->
    Key = cowboy_req:binding(key, Req0),

    case key_value_store_storage:get(Key) of
        {ok, Value} ->
            Response = #{
                <<"key">> => Key,
                <<"value">> => Value
            },

            reply_json(200, Response, Req0, State);

        {error, not_found} ->
            reply_json(
                404,
                #{<<"error">> => <<"Key not found">>},
                Req0,
                State
            )
    end;

handle_request(<<"DELETE">>, Req0, State) ->
    Key = cowboy_req:binding(key, Req0),

    case key_value_store_storage:clear(Key) of
        ok ->
            Response = #{
                <<"key">> => Key,
                <<"message">> => <<"Key deleted">>
            },

            reply_json(200, Response, Req0, State);

        {error, not_found} ->
            reply_json(
                404,
                #{<<"error">> => <<"Key not found">>},
                Req0,
                State
            )
    end;

handle_request(_Method, Req0, State) ->
    Response = #{<<"error">> => <<"Method not allowed">>},
    reply_json(405, Response, Req0, State).

reply_json(Status, Response, Req0, State) ->
    Body = jsx:encode(Response),

    Req = cowboy_req:reply(
        Status,
        #{<<"content-type">> => <<"application/json">>},
        Body,
        Req0
    ),

    {ok, Req, State}.

