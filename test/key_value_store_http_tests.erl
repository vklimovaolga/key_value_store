
-module(key_value_store_http_tests).

-include_lib("eunit/include/eunit.hrl").

http_test_() ->
    {setup,
        fun setup/0,
        fun cleanup/1,
        fun tests/1
    }.

setup() ->
    {ok, _} = application:ensure_all_started(inets),
    {ok, _} = application:ensure_all_started(key_value_store),
    ok.

cleanup(_State) ->
    application:stop(key_value_store),
    application:stop(inets).

tests(_State) ->
    [
        ?_test(test_put_and_get()),
        ?_test(test_get_missing_key()),
        ?_test(test_delete_key())
    ].

test_put_and_get() ->
    Url = "http://localhost:8081/store/http_test",

    {ok, {{_, 200, _}, _, _}} =
        httpc:request(
            put,
            {Url, [], "application/json", "{\"value\":\"Olga\"}"},
            [],
            []
        ),

    {ok, {{_, 200, _}, _, Body}} =
        httpc:request(Url),

    ?assertMatch(
        {match, _},
        re:run(Body, <<"Olga">>)
    ).

test_get_missing_key() ->
    Url = "http://localhost:8081/store/unknown_http_test",

    {ok, {{_, 404, _}, _, _}} =
        httpc:request(Url).

test_delete_key() ->
    Url = "http://localhost:8081/store/delete_http_test",

    {ok, {{_, 200, _}, _, _}} =
        httpc:request(
            put,
            {Url, [], "application/json", "{\"value\":\"temporary\"}"},
            [],
            []
        ),

    {ok, {{_, 200, _}, _, _}} =
        httpc:request(delete, {Url, []}, [], []),

    {ok, {{_, 404, _}, _, _}} =
        httpc:request(Url).
