# Node control
# NB: currently only supports starting nodes with -sname

.PHONY: qcu-shell \
	qcu-remsh \
	qcu-reload \
	qcu-restart \
	qcu-start \
	qcu-stop \
	qcu-status

# Config

NODENAME ?= $(PROJECT)
HOSTNAME ?= $(shell hostname -s)
NODE ?= $(NODENAME)@$(HOSTNAME)

QCU_ERL ?= erl -smp

QCU_CONFIG_OPT ?= $(if $(QCU_CONFIG),-config $(QCU_CONFIG),)
QCU_LAUNCH_OPT ?= $(if $(wildcard src/$(PROJECT_MOD).erl),-s $(PROJECT),)

QCU_SHELL_ERL ?= $(QCU_ERL)
QCU_SHELL_PATHS ?= $(CURDIR)/ebin $(APPS_DIR)/*/ebin $(DEPS_DIR)/*/ebin
QCU_SHELL_OPTS ?= $(QCU_CONFIG_OPT) -pa $(QCU_SHELL_PATHS) $(QCU_LAUNCH_OPT) $(QCU_SHELL_EXTRA)

QCU_START_PATHS ?= $(QCU_SHELL_PATHS)
QCU_START_OPTS ?= $(QCU_CONFIG_OPT) -pa $(QCU_START_PATHS) $(QCU_LAUNCH_OPT) $(QCU_START_EXTRA)

# Core targets

help::
	$(verbose) printf "%s\n" "" \
		"qcu.mk ctrl targets:" \
		"  qcu-shell       Run erlang node in foreground" \
		"  qcu-remsh       Connect to node started by ctrl" \
		"  qcu-restart     Stop then start the erlang node" \
		"  qcu-start       Start erlang node in background" \
		"  qcu-stop        Stop erlang node started by ctrl" \
		"  qcu-status      Get status of the erlang node"

# Plugin targets

$(foreach dep,$(QCU_SHELL_DEPS),$(eval $(call dep_target,$(dep))))

qcu-shell-deps: $(addprefix $(DEPS_DIR)/,$(QCU_SHELL_DEPS))
	$(verbose) for dep in $^; do $(MAKE) -C $$dep; done

qcu-shell: $(QCU_CONFIG) app qcu-shell-deps
	$(QCU_SHELL_ERL) -sname $(NODENAME) $(QCU_SHELL_OPTS)

qcu-remsh:
	$(QCU_ERL) -remsh $(NODE) -sname remsh-$(shell echo $$$$) $(QCU_REMSH_OPTS)

qcu-reload: app

qcu-restart: stop start

qcu-start: $(QCU_CONFIG) app
	$(QCU_ERL) -detached -sname $(NODENAME) $(QCU_START_OPTS)
	@(until epmd -names | grep $(NODENAME); do echo "Waiting for node to start..."; sleep 1; done)

qcu-status:
	@(epmd -names | grep $(NODENAME) || echo $$(tput setaf 1)$(NODENAME) stopped$$(tput sgr0))

qcu-stop:
	$(QCU_ERL) -eval "rpc:call('$(NODE)', init, stop, [])." -s init stop -sname admin -noshell
	@(while epmd -names | grep $(NODENAME); do echo "Waiting for node to stop..."; sleep 1; done)
