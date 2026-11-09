-module(key_value_store_storage_tests).

-include_lib("eunit/include/eunit.hrl").

storage_test_() ->
    {setup,
        fun setup/0,
        fun cleanup/1,
        fun tests/1
    }.

setup() ->
    {ok, Pid} = key_value_store_storage:start_link(),
    unlink(Pid),
    Pid.

cleanup(Pid) ->
    gen_server:stop(Pid).

tests(_Pid) ->
    [
        ?_test(test_set_and_get()),
        ?_test(test_update_value()),
        ?_test(test_get_missing_key()),
        ?_test(test_clear_key()),
        ?_test(test_clear_missing_key())
    ].

test_set_and_get() ->
    ok = key_value_store_storage:set(<<"name">>, <<"Olga">>),
    ?assertEqual(
        {ok, <<"Olga">>},
        key_value_store_storage:get(<<"name">>)
    ).

test_update_value() ->
    ok = key_value_store_storage:set(<<"name">>, <<"Olga">>),
    ok = key_value_store_storage:set(<<"name">>, <<"Anna">>),
    ?assertEqual(
        {ok, <<"Anna">>},
        key_value_store_storage:get(<<"name">>)
    ).

test_get_missing_key() ->
    ?assertEqual(
        {error, not_found},
        key_value_store_storage:get(<<"unknown">>)
    ).

test_clear_key() ->
    ok = key_value_store_storage:set(<<"name">>, <<"Olga">>),
    ok = key_value_store_storage:clear(<<"name">>),
    ?assertEqual(
        {error, not_found},
        key_value_store_storage:get(<<"name">>)
    ).

test_clear_missing_key() ->
    ?assertEqual(
        {error, not_found},
        key_value_store_storage:clear(<<"unknown">>)
    ).