#!/bin/bash

EJABBERD_CONFIG_PATH=ejabberd.yml erl -pa ebin -pa deps/*/ebin -pa test -pa deps/elixir/lib/*/ebin/ -s ejabberd \
 -name ejabberd@127.0.0.1 -setcookie ejabberd_cookie


