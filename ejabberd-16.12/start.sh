#!/bin/bash

EJABBERD_CONFIG_PATH=ejabberd.yml erl -pa ebin -pa deps/*/ebin -pa test -pa deps/elixir/lib/*/ebin/ -s ejabberd \
 -name ejabberd@localhost -setcookie ejabberd_cookie -detached


