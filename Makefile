

# This depends on Makefile.env which can be found here - https://github.com/sio/Makefile.venv/blob/master/Makefile.venv
#
# wget https://raw.githubusercontent.com/sio/Makefile.venv/master/Makefile.venv

# $(WORKDIR)/requirements.txt must contain all modules needed by octodns
#
# Example contents:
# 	octodns==0.9.21
# 	octodns-cloudflare==0.0.2

# $(WORKDIR)/.env will be sourced for environment variables if it exists. Be careful
# as this is sourced by make, not a shell, so make syntax must be used, e.g. make
# does not part single or double quotes so values with spaces are a no-go
#
# Example contents:
# 	export CLOUDFLARE_EMAIL=user@example.com
# 	export CLOUDFLARE_TOKEN=aBunchOfNumbers


WORKDIR=.
-include $(WORKDIR)/.env


.PHONY: doit 
doit: venv validate
	$(VENV)/octodns-sync --config-file config.yaml --doit


.PHONY: force 
force: venv validate
	$(VENV)/octodns-sync --config-file config.yaml --doit --force


.PHONY: interactive
interactive: venv
	. $(VENV)/activate && exec $(notdir $(SHELL))


.PHONY: sync
sync: venv validate
	$(VENV)/octodns-sync --config-file config.yaml



.PHONY: validate
validate: venv
	$(VENV)/octodns-validate --config-file config.yaml




# Last so as not to provide a default target
include Makefile.venv
