# Templates with mx

# Config

MX_DIR  ?= lib/mx
MX_     := $(MX_DIR)/mx.m4
MX_REPO ?= https://github.com/jflatow/mx.git
MX	 = m4 -P $(foreach V,$(MX_VARS),-D$V='$($V)') $(MX_)

# Core targets

all:: $(MX_)

# Sync targets

$(MX_DIR):
	git submodule add $(MX_REPO) $@

$(MX_DIR)/.git: $(MX_DIR)
	git submodule update --init $(@D)

$(MX_): $(MX_DIR)/.git
