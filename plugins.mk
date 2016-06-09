# All plugins

THIS := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
include $(THIS)/mk/ctrl.mk
include $(THIS)/mk/mx.mk
include $(THIS)/mk/npm.mk
