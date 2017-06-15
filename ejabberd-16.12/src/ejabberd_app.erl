%%%----------------------------------------------------------------------
%%% File    : ejabberd_app.erl
%%% Author  : Alexey Shchepin <alexey@process-one.net>
%%% Purpose : ejabberd's application callback module
%%% Created : 31 Jan 2003 by Alexey Shchepin <alexey@process-one.net>
%%%
%%%
%%% ejabberd, Copyright (C) 2002-2016   ProcessOne
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License along
%%% with this program; if not, write to the Free Software Foundation, Inc.,
%%% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%%%
%%%----------------------------------------------------------------------

-module(ejabberd_app).

-behaviour(ejabberd_config).
-author('alexey@process-one.net').

-behaviour(application).

-export([start/2, prep_stop/1, stop/1,
	 init/0, opt_type/1]).

-include("ejabberd.hrl").
-include("logger.hrl").

%%%
%%% Application API
%%%

start(normal, _Args) ->
    %% 启动lager
    ejabberd_logger:start(),

    % 将进程号写入文件中，由于我用的./run.sh 启动的系统，没有配置，这里也就是返回个ok, 啥也没做
    write_pid_file(),

    % 启动依赖app, 具体看　start_apps函数内的调用
    start_apps(),

    % 检查一个宏是否定义，如果定义了，启动elixir　app,　
    %% elixir我个人不是太喜欢^_^, 觉得不纯，花骚[个人观点]
    start_elixir_application(),

    %% 这里主要是检查ejabberd的模块是否都加载了，逻辑简单，　./ebin/ejabberd.app 里的模块　，
    ejabberd:check_app(ejabberd),

    %%
    % (ejabberd@localhost)8> code:which(randoms).
    % "/web/ejabberd_read/ejabberd-16.12/ebin/randoms.beam"
    % 找到了，还以为是一个外部文件，　结果还是在src下，进去瞄下
    % 进去看了下，就返回个ok ,好吧，你们城里人真会玩，我被打败了
    randoms:start(),

    %启动mnesia app
    db_init(),

    %注册ejabberd　进程，好像这个进程啥也不做，即然不是关心的代码段，就先丢一边，
    start(),

    % 建了张ets表，加载了一些数据，冒似是搞翻译之类的，
    translate:start(),

    %启动一个gen_server, 注册名称为　ejabberd_access_permissions，
    % ejabberd_access_permissions:show_current_definitions().
    % 看下面的返回结果，acl啥的，应该是跟权限控制相关的细节，后面具体用到的时候再探究细节，
    %     (ejabberd@localhost)11> ejabberd_access_permissions:show_current_definitions().
    % [{<<"console commands">>,
    %   {[ejabberd_ctl],
    %    [{acl,all}],
    %    [user_resources,update_list,update,unregister,stop_kindly,
    %     stop_all_connections,stop,status,set_master,set_loglevel,
    %     rotate_log,restore,restart,reopen_log,reload_config,
    %     registered_vhosts,registered_users,register,
    %     outgoing_s2s_number,oauth_revoke_token,oauth_list_tokens,
    %     oauth_list_scopes,oauth_issue_token|...]}},
    %  {<<"admin access">>,
    %   {[],
    %    [{acl,admin}],
    %    [user_resources,update_list,update,unregister,stop_kindly,
    %     stop_all_connections,status,set_master,set_loglevel,
    %     rotate_log,restore,restart,reopen_log,reload_config,
    %     registered_vhosts,registered_users,register,
    %     outgoing_s2s_number,oauth_revoke_token,oauth_list_tokens,
    %     oauth_list_scopes,oauth_issue_token|...]}},
    %  {<<"'commands' option compatibility shim">>,
    %   {[],[{access,none}],[]}}]
    ejabberd_access_permissions:start_link(),

    % 建了两个 ets 表
    % ejabberd_ctl_cmds, ejabberd_ctl_host_cmds
    ejabberd_ctl:init(),

    % mnesia表相关的，还有一点权限相关的，细节后面再看，
    ejabberd_commands:init(),

    % 将命令写入mnesia表，　
    % ejabberd commands
    % 好多命令　具体看 ejabberd_admin:get_commands_spec()
    ejabberd_admin:start(),

    % ejabberd_modules , 建　etf 表
    gen_mod:start(),

    %% 加入一些路径　
    %% "/web/ejabberd_read/ejabberd-16.12/deps/p1_utils/ebin/p1_http.beam"
    %% p1_http:start(),  　　估计是启动了一个http监听之类的 ,  这个后面再看细节，
    %% ejabberd_commands:register_commands(get_commands_spec()). 注册了一些命令，
    %% 本质就是往mnesia表里写数据，也只能　等　到用到的时候再排查细节
    ext_mod:start(),

    setup_if_elixir_conf_used(),

    % 加载配置文件
    ejabberd_config:start(),

    set_settings_from_config(),
    acl:start(),
    shaper:start(),
    connect_nodes(),
    Sup = ejabberd_sup:start_link(),
    ejabberd_rdbms:start(),
    ejabberd_riak_sup:start(),
    ejabberd_redis:start(),
    ejabberd_sm:start(),
    cyrsasl:start(),
    % Profiling
    %ejabberd_debug:eprof_start(),
    %ejabberd_debug:fprof_start(),
    maybe_add_nameservers(),
    ejabberd_auth:start(),
    ejabberd_oauth:start(),
    gen_mod:start_modules(),

    % 先跳　到这里查看下
    ejabberd_listener:start_listeners(),
    register_elixir_config_hooks(),
    ?INFO_MSG("ejabberd ~s is started in the node ~p", [?VERSION, node()]),
    Sup;
start(_, _) ->
    {error, badarg}.

%% Prepare the application for termination.
%% This function is called when an application is about to be stopped,
%% before shutting down the processes of the application.
prep_stop(State) ->
    ejabberd_listener:stop_listeners(),
    ejabberd_admin:stop(),
    broadcast_c2s_shutdown(),
    gen_mod:stop_modules(),
    timer:sleep(5000),
    State.

%% All the processes were killed when this function is called
stop(_State) ->
    ?INFO_MSG("ejabberd ~s is stopped in the node ~p", [?VERSION, node()]),
    delete_pid_file(),
    %%ejabberd_debug:stop(),
    ok.


%%%
%%% Internal functions
%%%

start() ->
    spawn_link(?MODULE, init, []).

init() ->
    register(ejabberd, self()),
    loop().

loop() ->
    receive
	_ ->
	    loop()
    end.

db_init() ->
    ejabberd_config:env_binary_to_list(mnesia, dir),
    MyNode = node(),
    DbNodes = mnesia:system_info(db_nodes),
    case lists:member(MyNode, DbNodes) of
	true ->
	    ok;
	false ->
	    ?CRITICAL_MSG("Node name mismatch: I'm [~s], "
			  "the database is owned by ~p", [MyNode, DbNodes]),
	    ?CRITICAL_MSG("Either set ERLANG_NODE in ejabberdctl.cfg "
			  "or change node name in Mnesia", []),
	    erlang:error(node_name_mismatch)
    end,
    case mnesia:system_info(extra_db_nodes) of
	[] ->
	    mnesia:create_schema([node()]);
	_ ->
	    ok
    end,
    ejabberd:start_app(mnesia, permanent),
    mnesia:wait_for_tables(mnesia:system_info(local_tables), infinity).

connect_nodes() ->
    Nodes = ejabberd_config:get_option(
              cluster_nodes,
              fun(Ns) ->
                      true = lists:all(fun is_atom/1, Ns),
                      Ns
              end, []),
    lists:foreach(fun(Node) ->
                          net_kernel:connect_node(Node)
                  end, Nodes).

%% If ejabberd is running on some Windows machine, get nameservers and add to Erlang
maybe_add_nameservers() ->
    case os:type() of
	{win32, _} -> add_windows_nameservers();
	_ -> ok
    end.

add_windows_nameservers() ->
    IPTs = win32_dns:get_nameservers(),
    ?INFO_MSG("Adding machine's DNS IPs to Erlang system:~n~p", [IPTs]),
    lists:foreach(fun(IPT) -> inet_db:add_ns(IPT) end, IPTs).


broadcast_c2s_shutdown() ->
    Children = ejabberd_sm:get_all_pids(),
    lists:foreach(
      fun(C2SPid) when node(C2SPid) == node() ->
	      C2SPid ! system_shutdown;
	 (_) ->
	      ok
      end, Children).

%%%
%%% PID file
%%%

write_pid_file() ->
    case ejabberd:get_pid_file() of
	false ->
	    ok;
	PidFilename ->
	    write_pid_file(os:getpid(), PidFilename)
    end.

write_pid_file(Pid, PidFilename) ->
    case file:open(PidFilename, [write]) of
	{ok, Fd} ->
	    io:format(Fd, "~s~n", [Pid]),
	    file:close(Fd);
	{error, Reason} ->
	    ?ERROR_MSG("Cannot write PID file ~s~nReason: ~p", [PidFilename, Reason]),
	    throw({cannot_write_pid_file, PidFilename, Reason})
    end.

delete_pid_file() ->
    case ejabberd:get_pid_file() of
	false ->
	    ok;
	PidFilename ->
	    file:delete(PidFilename)
    end.

set_settings_from_config() ->
    Level = ejabberd_config:get_option(
              loglevel,
              fun(P) when P>=0, P=<5 -> P end,
              4),
    ejabberd_logger:set(Level),
    Ticktime = ejabberd_config:get_option(
                 net_ticktime,
                 opt_type(net_ticktime),
                 60),
    net_kernel:set_net_ticktime(Ticktime).

start_apps() ->
    crypto:start(),
    ejabberd:start_app(sasl),
    ejabberd:start_app(ssl),
    ejabberd:start_app(fast_yaml),
    ejabberd:start_app(fast_tls),
    ejabberd:start_app(xmpp),
    ejabberd:start_app(cache_tab).

opt_type(net_ticktime) ->
    fun (P) when is_integer(P), P > 0 -> P end;
opt_type(cluster_nodes) ->
    fun (Ns) -> true = lists:all(fun is_atom/1, Ns), Ns end;
opt_type(loglevel) ->
    fun (P) when P >= 0, P =< 5 -> P end;
opt_type(modules) ->
    fun (Mods) ->
	    lists:map(fun ({M, A}) when is_atom(M), is_list(A) ->
			      {M, A}
		      end,
		      Mods)
    end;
opt_type(_) -> [cluster_nodes, loglevel, modules, net_ticktime].

setup_if_elixir_conf_used() ->
  case ejabberd_config:is_using_elixir_config() of
    true -> 'Elixir.Ejabberd.Config.Store':start_link();
    false -> ok
  end.

register_elixir_config_hooks() ->
  case ejabberd_config:is_using_elixir_config() of
    true -> 'Elixir.Ejabberd.Config':start_hooks();
    false -> ok
  end.

start_elixir_application() ->
    case ejabberd_config:is_elixir_enabled() of
	true ->
	    case application:ensure_started(elixir) of
		ok -> ok;
		{error, _Msg} -> ?ERROR_MSG("Elixir application not started.", [])
	    end;
	_ ->
	    ok
    end.
