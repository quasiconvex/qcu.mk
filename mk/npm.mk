# Node packages

# Config

NPM     ?= npm
NPM_DIR ?= lib/node
NPM_    := $(NPM_DIR)/node_modules

# Core targets

all:: $(NPM_)

# Sync targets

$(NPM_DIR):
	mkdir -p $@

$(NPM_DIR)/package.json:
	echo '{"private": true}' > $@

$(NPM_): $(NPM_DIR) $(NPM_DIR)/package.json
	(cd $< && $(NPM) install)
