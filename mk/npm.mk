# Node packages

# Config

NPM ?= npm
NPM_DIR ?= lib/node
NPM_MOD ?= $(NPM_DIR)/node_modules

# Core targets

all:: $(NPM_MOD)

# Sync targets

$(NPM_DIR):
	mkdir -p $@

$(NPM_MOD): $(NPM_DIR) $(NPM_DIR)/package.json
	(cd $< && $(NPM) install)